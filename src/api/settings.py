import os

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    api_proxy_host: str = "api"
    redis_host: str = os.environ["REDIS_HOST"]
    kafka_servers: str | None = os.environ.get("KAFKA_SERVERS")


settings = Settings()