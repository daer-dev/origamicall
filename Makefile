all:
	@echo "This Makefile is only for production install purposes"

install:
	docker build -t origamicall/webo .

run:
	docker run -itd -p 127.0.0.1:3000:3000 \
		--name origamicall-webo \
		-w /srv \
		-v /home/origamicall/webo:/srv \
		-v /home/origamicall/audios_test/audio_libs:/srv/public/resources/libs/audios \
		-v /home/origamicall/audios_test/VMFiles:/srv/public/resources/ivr/nodes/voicemail/audios \
		-i origamicall/webo

run-prod:
	docker run -itd -p 127.0.0.1:3003:3000 \
		--name origamicall-webo-prod \
		-w /srv \
		-v /home/origamicall/webo-prod:/srv \
		-v /home/origamicall/audios_prod/audio_libs:/srv/public/resources/libs/audios \
		-v /home/origamicall/audios_prod/VMFiles:/srv/public/resources/ivr/nodes/voicemail/audios \
		-i origamicall/webo

clean:
	- docker rm -f origamicall-webo

clean-prod:
	- docker rm -f origamicall-webo-prod

clean-all: clean
	docker rmi origamicall/webo

attach:
	docker logs origamicall-webo
	docker attach origamicall-webo

update:
	git reset --hard
	git pull
	make clean
	make run

update-prod:
	make clean-prod
	make run-prod
