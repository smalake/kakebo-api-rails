setup:
	docker-compose build
	docker-compose run web rails db:create db:migrate
	docker-compose up -d

up:
	docker-compose up -d

down:
	docker-compose down

migrate:
	docker-compose run web rails db:migrate

logs:
	docker-compose logs