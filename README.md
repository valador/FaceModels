echo -n myuser:mypasswd | base64
sudo kubectl apply -k cred/

## Delete Images from the Private Docker Registry
### Remove one image from your Docker Registry

Let's remove ubuntu 18.04 tag and the image from the Docker Registry. In order to do that we need to get the Docker-Content-Digest of the tag. Once you execute the command below, the sha value for ubuntu 18.04 tag will be returned to the console. You may copy that output.
```bash
$ curl -v --silent -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -X GET http://localhost:5000/v2/ubuntu/manifests/18.04 2>&1 | grep Docker-Content-Digest | awk '{print ($3)}'
```
Now let's delete the image by using the Docker-Content-Digest ID which was returned.
```bash
$ curl -v -X DELETE http://localhost:5000/v2/ubuntu/manifests/<sha_value_you_received_from_the_previous_command>
```
Once you run this command you will receive a successful reply(status code 202).
### Run the garbage collector

Now we need to run the Docker Garbage Collector to remove the image completely from the file system. From this step, you will be able to reduce the storage used.
```bash
$ docker exec localregistry bin/registry garbage-collect --delete-untagged /etc/docker/registry/config.yml
```
You will see that all the layers will be listed and only the related layers will get selected to be deleted.

    PLEASE NOTE in registry version 2.7.1 :- At this moment you have successfully deleted your image. But if you again push the same image(Ubuntu 18.04) to your local Docker Registry, you will see a reply saying the image layers still exist. In order to avoid this you need to restart you Docker Registry.
```bash
$ docker restart localregistry
```
Now you can push the same image and you will see that its getting pushed.

### Kubernetes with Kaniko
For build on kubernetes with Kaniko need change COPY in Dockerfile to assets/3dmm_assets and assets/pretrained_models

torch 	torchvision 	Python
main / nightly 	main / nightly 	>=3.8, <=3.11
2.1 	0.16 	    >=3.8, <=3.11
2.0 	0.15 	    >=3.8, <=3.11
1.13 	0.14 	    >=3.7.2, <=3.10
---
need code update for:
face-alignment==1.2
face_alignment.LandmarksType._3D to face_alignment.LandmarksType.THREE_D.

## NextFace
#### Single Image
```bash
python optimizer.py --input input/emma1.jpg --output output
```
#### Batch for same face
python optimizer.py --sharedIdentity --input data/input --output data/output
---
## HRN
```bash
CUDA_VISIBLE_DEVICES=0 python3 demo.py --input_type single_view --input_root ./assets/examples/single_view_image --output_root ./assets/custom/output
```

pip install tensorflow[and-cuda]==2.14