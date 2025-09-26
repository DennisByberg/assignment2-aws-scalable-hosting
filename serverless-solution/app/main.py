from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
import os

app = FastAPI()

# Static files and templates
app.mount("/static", StaticFiles(directory="static"), name="static")
templates = Jinja2Templates(directory="templates")

# AWS Configuration
API_GATEWAY_URL = os.getenv("API_GATEWAY_URL", "")
CONTACT_API_URL = os.getenv("CONTACT_API_URL", "")


@app.get("/", response_class=HTMLResponse)
async def read_root(request: Request):
    return templates.TemplateResponse(
        "index.html",
        {
            "request": request,
            "api_gateway_url": API_GATEWAY_URL,
            "contact_api_url": CONTACT_API_URL,
        },
    )
