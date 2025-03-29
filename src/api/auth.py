from uuid import uuid4
from typing import Annotated


from fastapi import (
    FastAPI,
    Depends,
    HTTPException,
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


@app.post("/auth")
async def signin(
    krc_token: KRCToken,
    r: Annotated[redis.Redis, Depends(redis_client)],
):
    username = r.get(krc_token.token)
    logger.info(f"{krc_token.token} = {username}")
    if not username:
        raise HTTPException(status_code=400, detail="not authorized")
    return {
        "username": username,
    }
