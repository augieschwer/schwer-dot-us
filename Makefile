# Define the package manager (npm, pnpm, yarn, or bun)
PM = npm

.PHONY: dev build preview clean help

## dev: Start the VitePress development server
dev:
	$(PM) run blog:dev

## build: Build the VitePress site for production
build:
	$(PM) run blog:build

## preview: Preview the production build locally
preview:
	$(PM) run blog:preview

## clean: Remove the build output (standard path)
clean:
	rm -rf .vitepress/dist
	rm -rf .vitepress/cache

## help: Show available commands
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'
