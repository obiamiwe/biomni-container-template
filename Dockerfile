FROM python:3.11-slim
WORKDIR /app
RUN apt-get update && apt-get install -y \
    gcc g++ git curl \
    && rm -rf /var/lib/apt/lists/*

# --- Application code ---
# The lines below assume a Flask app on top of the open-source Biomni agent
# (https://github.com/snap-stanford/Biomni). Adjust filenames/paths to match
# your own app's structure.
COPY pyproject.toml .
COPY biomni/ biomni/
COPY app.py .
COPY ui.html .
COPY static/ static/

# --- Python dependencies ---
# Torch CPU-only (swap for a GPU index-url if your deployment has GPU access)
RUN pip install --no-cache-dir torch --index-url https://download.pytorch.org/whl/cpu

# Core web + agent stack, plus AWS Bedrock support (boto3, langchain-aws) —
# include these even if you're not on Bedrock yet; trivial to leave unused.
RUN pip install --no-cache-dir \
    flask gunicorn anthropic boto3 langchain-aws \
    chromadb sentence-transformers \
    plotly scipy scikit-posthocs scikit-learn \
    pandas numpy openpyxl \
    pillow PyPDF2 python-docx markdown \
    requests beautifulsoup4 lxml \
    matplotlib seaborn statsmodels \
    langchain langchain-core langchain-openai \
    langchain-community langchain-anthropic \
    langchain-text-splitters langgraph \
    tiktoken openai python-dotenv \
    biopython scanpy anndata gseapy \
    googlesearch-python mcp tqdm pydantic \
    together groq transformers datasets networkx

RUN mkdir -p /app/figures
EXPOSE 5001
# Update "app:app" if your entrypoint file/Flask object is named differently
CMD ["gunicorn", "--bind", "0.0.0.0:5001", "--workers", "1", "--threads", "8", "--timeout", "300", "app:app"]
