"""Run against flutter build web served at localhost:8765; no Google key needed."""
import json
from pathlib import Path
from playwright.sync_api import sync_playwright

OUTPUT = Path('docs/evidence/issue-19')
OUTPUT.mkdir(parents=True, exist_ok=True)
with sync_playwright() as p:
    browser = p.chromium.launch()
    context = browser.new_context(viewport={'width': 430, 'height': 932}, device_scale_factor=1,
        geolocation={'latitude': -34.6037, 'longitude': -58.3816}, permissions=['geolocation', 'clipboard-read', 'clipboard-write'])
    page = context.new_page()
    requests = []
    mode = {'status': 200}
    def mock(route):
        request = route.request
        assert request.method == 'POST'
        assert 'x-goog-api-key' not in request.headers
        body = request.post_data_json
        requests.append({'path': request.url.split('/api/')[1], 'body': body})
        if request.url.endswith('/nearby'):
            assert body['locationRestriction']['circle']['center'] == {'latitude': -34.6037, 'longitude': -58.3816}
        route.fulfill(status=mode['status'], content_type='application/json', body=json.dumps({'places': [
            {'id': 'ChIJ_demo_cafe', 'displayName': {'text': 'Café del Centro (simulado)'}, 'formattedAddress': 'Av. Corrientes 1234, Buenos Aires'},
            {'id': 'ChIJ_demo_kiosco', 'displayName': {'text': 'Kiosco Obelisco (simulado)'}, 'formattedAddress': 'Av. Corrientes 1200, Buenos Aires'}
        ]}))
    page.route('**/api/places/*', mock)
    def home():
        page.goto('http://localhost:8765')
        page.wait_for_timeout(5000)
        page.locator('flt-semantics-placeholder').evaluate('(e) => e.click()')
    home()
    page.get_by_text('Google Reseñas', exact=True).click()
    page.get_by_role('button', name='Buscar cerca mío').click()
    page.wait_for_timeout(2000)
    page.get_by_text('Café del Centro (simulado)', exact=False).wait_for()
    page.screenshot(path=str(OUTPUT / '01-negocios-cercanos.png'))
    page.get_by_text('Café del Centro (simulado)', exact=False).click()
    page.wait_for_timeout(2000)
    page.screenshot(path=str(OUTPUT / '02-etiqueta-google.png'))
    page.get_by_role('button', name='Copiar link', exact=True).click()
    assert page.evaluate('navigator.clipboard.readText()') == 'https://search.google.com/local/writereview?placeid=ChIJ_demo_cafe'
    home()
    page.get_by_text('Google Reseñas', exact=True).click()
    page.wait_for_timeout(1000)
    page.locator('[aria-description="Collapsed"]').evaluate('(e) => e.click()')
    page.get_by_role('textbox', name='Nombre y localidad').fill('Café del Centro Buenos Aires')
    page.get_by_role('button', name='Buscar negocio', exact=True).click()
    page.get_by_text('Café del Centro (simulado)', exact=False).wait_for()
    page.screenshot(path=str(OUTPUT / '03-busqueda-nombre.png'))
    mode['status'] = 503
    page.get_by_role('button', name='Buscar negocio', exact=True).click()
    page.wait_for_function("document.querySelector('flt-semantics-host').innerHTML.includes('La búsqueda automática no está disponible.')")
    page.screenshot(path=str(OUTPUT / '04-sin-clave.png'))
    for title, field, value in [('WhatsApp', 'Celular argentino', '011 15 2345-6789'), ('Instagram', 'Usuario o enlace de Instagram', '@mi_comercio')]:
        home()
        page.get_by_text(title, exact=True).click()
        page.get_by_role('textbox', name=field, exact=False).fill(value)
        page.get_by_role('button', name='Ver etiqueta', exact=True).click()
        page.wait_for_timeout(1500)
        page.get_by_role('button', name='Copiar link', exact=True).click()
        link = page.evaluate('navigator.clipboard.readText()')
        assert link == ('https://wa.me/5491123456789' if title == 'WhatsApp' else 'https://instagram.com/mi_comercio')
        with page.expect_download() as download:
            page.get_by_role('button', name='Guardar imagen', exact=True).click()
        assert download.value.suggested_filename.endswith('.png')
    (OUTPUT / 'requests.json').write_text(json.dumps(requests, indent=2, ensure_ascii=False) + '\n')
    browser.close()
print('Capturas y flujos verificados')
