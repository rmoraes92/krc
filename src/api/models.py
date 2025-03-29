from pydantic import BaseModel

class NewMessage(BaseModel):
    channel: str
    body: str

class KRCToken(BaseModel):
    token: str

class Channel(BaseModel):
    name: str

class Credentials(BaseModel):
    username: str
    password: str
