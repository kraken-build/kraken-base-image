
.build/Dockerfile: templates/Dockerfile bin/pyenv-dockerfile-generator.py bin/render.py
	mkdir -p .build
	bin/render.py templates/Dockerfile > .build/Dockerfile

.PHONY: build
build: .build/Dockerfile
	docker buildx build --platform linux/amd64 -f .build/Dockerfile . --cache-from ghcr.io/kraken-build/kraken:cache --cache-to ghcr.io/kraken-build/kraken:cache --tag ghcr.io/kraken-build/kraken:$(shell git describe --tags --dirty) --push

# ,linux/arm64
