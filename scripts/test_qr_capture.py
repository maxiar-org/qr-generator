"""Run against local web build: python3 scripts/test_qr_capture.py."""
from pathlib import Path
from playwright.sync_api import sync_playwright

root = Path(__file__).resolve().parents[1]
with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()
    page.goto("http://localhost:8765")
    page.wait_for_function("typeof window.qrCapture === 'function'")
    for name in ["link", "emv", "interoperable", "unrelated"]:
        page.evaluate("window.result = undefined; void window.qrCapture(false).then(v => window.result = v)")
        page.locator('input[type=file]').set_input_files(str(root / f"test/fixtures/mercado_pago/{name}.png"))
        page.wait_for_function("window.result !== undefined")
        assert page.evaluate("window.result") == (root / f"test/fixtures/mercado_pago/{name}.txt").read_text()
    page.evaluate("void window.qrCapture(false)")
    page.locator('input[type=file]').set_input_files(str(root / "test/fixtures/mercado_pago/blank.png"))
    page.get_by_text("No encontramos un QR").wait_for()
    page.get_by_role("button", name="Cancelar").click()

    # Cancellation before permission resolves must stop the late stream.
    page.evaluate("""() => {
        window.stopped = false;
        navigator.mediaDevices.getUserMedia = () => new Promise(resolve => window.grantCamera = resolve);
        void window.qrCapture(true);
    }""")
    page.get_by_role("button", name="Cancelar").click()
    page.evaluate("grantCamera({getTracks: () => [{stop: () => window.stopped = true}]})")
    page.wait_for_function("window.stopped")
    # Escape closes the scanner, including a pending permission request.
    page.evaluate("void window.qrCapture(true)")
    page.keyboard.press("Escape")
    assert page.locator("dialog").count() == 0
    browser.close()
print("QR image decoding: passed")
