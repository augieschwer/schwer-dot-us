.PHONY: dev build preview clean
dev:
	npm run blog:dev
build:
	npm run blog:build
preview:
	npm run blog:preview
clean:
	rm -rf .vitepress/dist
	rm -rf .vitepress/cache
