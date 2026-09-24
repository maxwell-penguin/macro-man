from fastapi import FastAPI

app = FastAPI(title="Cal-AI API")


@app.get("/health")
def health():
    return {"status": "ok"}
