SHELL := /bin/bash

.PHONY: prepear-hrn
prepear-hrn:
	mkdir -p ${PWD}/HRN/workspace/assets/3dmm_assets/BFM
	mkdir -p ${PWD}/HRN/workspace/assets/3dmm_assets/bfm_albedo_map_basis
	mkdir -p ${PWD}/HRN/workspace/assets/3dmm_assets/template_mesh
	mkdir -p ${PWD}/HRN/workspace/assets/pretrained_models
	mkdir -p ${PWD}/HRN/workspace/assets/pretrained_models/hrn_v1.1
	mkdir -p ${PWD}/HRN/workspace/assets/custom/input
	mkdir -p ${PWD}/HRN/workspace/assets/custom/output
## build image
.PHONY: build-hrn build-nf
build-hrn:
	docker build -f HRN/workspace/Dockerfile --progress=plain -t hrn HRN/workspace &> build_hrn.log
build-nf:
	docker build -f NextFace/Dockerfile --progress=plain --build-arg CACHEBUST=`date +%s` -t nextface . &> build_nf.log
.PHONY: run-hrn run-nf
run-hrn:
	docker run --rm -it \
			   --ipc=host \
			   --net=host \
			   --gpus=all \
			   -v ./HRN/workspace/assets/custom:/home/lab/HRN/assets/custom \
			   hrn
run-nf:
	docker run --rm -it \
			   --ipc=host \
			   --net=host \
			   --gpus=all \
			   -v ./NextFace/input:/home/lab/NextFace/input \
			   -v ./NextFace/output:/home/lab/NextFace/output \
			   -v ${PWD}/NextFace/optimConfig.ini:/home/lab/NextFace/optimConfig.ini \
			   nextface
.PHONY: ps
ps:
	docker ps --format \
	"table {{.ID}}\t{{.Status}}\t{{.Names}}"

.PHONY: hrn-build hrn-build-down hrn-build-logs
hrn-build:
	sudo kubectl apply -f ./context-volume.yml
	sudo kubectl apply -f ./context-volume-claim.yml
	sudo kubectl apply -f ./hrn-build.yml
hrn-build-down:
	sudo kubectl delete -f ./hrn-build.yml
	sudo kubectl delete -f ./context-volume-claim.yml
	sudo kubectl delete -f ./context-volume.yml
hrn-build-logs:
	sudo kubectl logs -n default -f build-hrn
