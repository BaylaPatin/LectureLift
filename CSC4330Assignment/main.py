from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import json
from pathlib import Path
from fastapi.responses import HTMLResponse

app = FastAPI(
    title="Books API",
    description="A simple FastAPI app using JSON as a database, demonstrating GET, POST, PUT, DELETE and HTML response for book management.",
    version="1.0.0"
)

DATA_FILE = Path(__file__).parent / "books_data.json"

def read_data():
    """Read JSON file and return its contents."""
    try:
        with open(DATA_FILE, "r") as f:
            return json.load(f)
    except Exception as e:
        print("Error reading JSON file:", e)
        return {"books": []}

def write_data(data):
    """Write data back to JSON file."""
    with open(DATA_FILE, "w") as f:
        json.dump(data, f, indent=4)

class Book(BaseModel):
    isbn: str
    title: str
    author: str
    description: str
    cover_url: str = None
    year_published: int = None
    pages: int = None

@app.get("/books", response_model=list[Book])
def list_books():
    """Return all books from books_data.json."""
    data = read_data()
    return data["books"]

@app.get("/books/{isbn}", response_model=Book)
def get_book(isbn: str):
    """Return a single book by its ISBN."""
    data = read_data()
    for book in data["books"]:
        if book["isbn"] == isbn:
            return book
    raise HTTPException(status_code=404, detail="Book not found")

@app.post("/books", response_model=Book)
def add_book(book: Book):
    """Add a new book to the JSON file."""
    data = read_data()
    if any(b["isbn"] == book.isbn for b in data["books"]):
        raise HTTPException(status_code=400, detail="Book with this ISBN already exists")
    data["books"].append(book.dict())
    write_data(data)
    return book

@app.put("/books/{isbn}", response_model=Book)
def update_book(isbn: str, book: Book):
    """Update an existing book identified by its ISBN."""
    data = read_data()
    for idx, b in enumerate(data["books"]):
        if b["isbn"] == isbn:
            data["books"][idx] = book.dict()
            write_data(data)
            return book
    raise HTTPException(status_code=404, detail="Book not found")

@app.delete("/books/{isbn}")
def delete_book(isbn: str):
    """Delete a book by its ISBN."""
    data = read_data()
    for idx, b in enumerate(data["books"]):
        if b["isbn"] == isbn:
            deleted = data["books"].pop(idx)
            write_data(data)
            return {"deleted": deleted}
    raise HTTPException(status_code=404, detail="Book not found")

@app.get("/books/{isbn}/cover", response_class=HTMLResponse)
def show_book_cover(isbn: str):
    """
    Show an HTML page with the book cover and details embedded.
    This demonstrates returning HTML instead of JSON.
    """
    data = read_data()
    for book in data["books"]:
        if book["isbn"] == isbn:
            cover_img = f'<img src="{book["cover_url"]}" alt="book cover" style="max-width:300px; height:auto; border: 1px solid #ddd;" />' if book.get("cover_url") else '<p>No cover image available</p>'
            year_info = f" ({book['year_published']})" if book.get("year_published") else ""
            pages_info = f"<p><strong>Pages:</strong> {book['pages']}</p>" if book.get("pages") else ""
            
            return f"""
            <html>
              <head>
                <title>{book['title']} by {book['author']}</title>
                <style>
                  body {{ font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }}
                  .book-container {{ display: flex; gap: 30px; align-items: flex-start; }}
                  .book-info {{ flex: 1; }}
                  .cover {{ flex-shrink: 0; }}
                  h1 {{ color: #333; margin-bottom: 10px; }}
                  .author {{ color: #666; font-size: 1.2em; margin-bottom: 20px; }}
                  .isbn {{ color: #999; font-size: 0.9em; }}
                  .description {{ line-height: 1.6; margin-top: 20px; }}
                </style>
              </head>
              <body>
                <div class="book-container">
                  <div class="cover">
                    {cover_img}
                  </div>
                  <div class="book-info">
                    <h1>{book['title']}{year_info}</h1>
                    <p class="author">by {book['author']}</p>
                    <p class="isbn"><strong>ISBN:</strong> {book['isbn']}</p>
                    {pages_info}
                    <div class="description">
                      <strong>Description:</strong><br>
                      {book['description']}
                    </div>
                  </div>
                </div>
              </body>
            </html>
            """
    raise HTTPException(status_code=404, detail="Book not found")