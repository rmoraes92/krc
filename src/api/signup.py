from typing import Annotated


from fastapi import (
    FastAPI,
    Depends,
)
from fastapi.middleware.cors import CORSMiddleware

from models import *
from clients import *

app = FastAPI()

origins = [
    "*",
    "http://localhost",
    "http://localhost:8080",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.post("/signup")
async def signup(
    credentials: Credentials,
    r: Annotated[redis.Redis, Depends(redis_client)],
):
    r.set(
        credentials.username,
        credentials.password,
    )
