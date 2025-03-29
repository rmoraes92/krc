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


@app.post("/signin")
async def signin(
    credentials: Credentials,
    r: Annotated[redis.Redis, Depends(redis_client)],
):
    password = r.get(credentials.username)
    if password:
        if password.decode("utf8") == credentials.password:
            token = str(uuid4())
            r.set(token, credentials.username)
            return {"token": token}

    raise HTTPException(status_code=401, detail="incorrect credentials")
