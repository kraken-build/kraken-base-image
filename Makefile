
build/Dockerfile: templates/Dockerfile bin/pyenv-dockerfile-generator.py bin/render.py
	mkdir -p build
	bin/render.py templates/Dockerfile > build/Dockerfile
