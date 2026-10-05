// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import mermaid from 'astro-mermaid';

// https://astro.build/config
export default defineConfig({
	site: 'https://maxiar-org.github.io',
	base: '/qr-generator/',
	integrations: [
		mermaid({
			theme: 'neutral',
			autoTheme: true,
		}),
		starlight({
			title: 'Generador de QR',
			description:
				'Guía de uso y arquitectura del Generador de QR para cartelería de comercios.',
			defaultLocale: 'root',
			locales: {
				root: { label: 'Español', lang: 'es' },
			},
			social: [
				{
					icon: 'github',
					label: 'GitHub',
					href: 'https://github.com/maxiar-org/qr-generator',
				},
			],
			sidebar: [
				{
					label: 'Guía de uso para Maxi',
					items: [{ autogenerate: { directory: 'guia-de-uso' } }],
				},
				{
					label: 'Arquitectura',
					items: [{ autogenerate: { directory: 'arquitectura' } }],
				},
				{
					label: 'Decisiones',
					items: [{ autogenerate: { directory: 'decisiones' } }],
				},
			],
		}),
	],
});
