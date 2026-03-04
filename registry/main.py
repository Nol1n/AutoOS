"""Minimal FastAPI registry stub (PHASE1 placeholder)
Provides /health and /index.json (static for now).
"""
from fastapi import FastAPI
from fastapi.responses import JSONResponse

app = FastAPI()


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/index.json")
def index():
    # static example index; real index will be generated during PHASE5
    return JSONResponse({
        "plugins": [],
        "version": "0.0.0"
    })
