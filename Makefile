MKDOCS_INS_VER = v9.7.5-2

.PHONY: docs
docs:
	docker run --rm -v $$(pwd):/docs --entrypoint mkdocs ghcr.io/eda-labs/mkdocs-material:$(MKDOCS_INS_VER) build --clean --strict

# serve the site locally using mkdocs-material insiders container
.PHONY: serve-insiders
serve-insiders:
	docker run -it --rm -p 8001:8000 -v $$(pwd):/docs ghcr.io/eda-labs/mkdocs-material:$(MKDOCS_INS_VER)

# serve the site locally using mkdocs-material insiders container using dirty-reloader
.PHONY: serve-insiders-dirty
serve-insiders-dirty:
	docker run -it --rm -p 8001:8000 -v $$(pwd):/docs ghcr.io/eda-labs/mkdocs-material:$(MKDOCS_INS_VER) serve --dirtyreload -a 0.0.0.0:8000

.PHONY: serve-docs
serve-docs: serve-insiders

.PHONY: htmltest
htmltest:
	docker run --rm -v $$(pwd):/docs --entrypoint mkdocs ghcr.io/eda-labs/mkdocs-material:$(MKDOCS_INS_VER) build --clean --strict
	docker run --rm -v $$(pwd):/test wjdp/htmltest --conf ./site/htmltest.yml
	rm -rf ./site

build-insiders:
	docker run -v $$(pwd):/docs --entrypoint mkdocs ghcr.io/eda-labs/mkdocs-material:$(MKDOCS_INS_VER) build --clean --strict

push-docs: # push docs to gh-pages branch manually. Use when pipeline misbehaves
	docker run -v ${SSH_AUTH_SOCK}:/ssh-agent --env SSH_AUTH_SOCK=/ssh-agent --env GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" -v $$(pwd):/docs --entrypoint mkdocs ghcr.io/srl-labs/mkdocs-material-insiders:$(MKDOCS_INS_VER) gh-deploy --force --strict

deploy-clab-topo:
	sudo modprobe bonding mmiimon=100 mode=802.3ad lacp_rate=fast
	CLAB_LABDIR_BASE=${HOME} containerlab deploy -t ./clab/srx.clab.yml --reconfigure

onboard-clab-topo-eda:
	# Prepare for onboarding
	sudo mkdir -p /opt/srexperts
	sudo chown -R workshop:workshop /opt/srexperts
	bash $$(pwd)/eda/record-init-tx.sh
	# Template EDA onboarding resources
	docker run --rm -e INSTANCE_ID=$$(echo -n ${INSTANCE_ID}) -e EVENT_PASSWORD="$$(echo -n ${EVENT_PASSWORD})" -e SSH_PUBLIC_KEY="$$(echo -n ${SSH_PUBLIC_KEY})" -u $$(id -u):$$(id -g) -v $$(pwd)/eda/topo-onboard/clab:/work ghcr.io/hellt/envsubst:0.2.0
	# Apply Clab onboarding to EDA
	kubectl apply -f $$(pwd)/eda/topo-onboard/clab
	# Apply fabric resorces to EDA
	bash $$(pwd)/eda/cleanup-pools.sh
	docker run --rm -e INSTANCE_ID=$$(echo -n ${INSTANCE_ID}) -e EVENT_PASSWORD="$$(echo -n ${EVENT_PASSWORD})" -e LLM_API_KEY="$$(echo -n ${LLM_API_KEY})" -u $$(id -u):$$(id -g) -v $$(pwd)/eda/fabric:/work ghcr.io/hellt/envsubst:0.2.0
	kubectl apply -f $$(pwd)/eda/fabric
