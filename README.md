<div align="center">

  # Ampere AI Text-to-SQL
  
  **Talk to your data using Open WebUI and LlamaIndex on Ampere CPUs**
  
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
  [![Platform](https://img.shields.io/badge/Platform-Ampere%20Altra-blue)](https://amperecomputing.com)
  [![Docker](https://img.shields.io/badge/Docker-Enabled-2496ED?logo=docker)](https://docs.docker.com/get-docker/)

</div>

---

## Overview

This repository demonstrates the Text-to-SQL capabilities of AI models running on the Ampere platform. By combining **Open WebUI Functions** with **LlamaIndex**, this demo bridges the gap between natural language questions and complex database queries, allowing users to analyze data without writing code.

### The Challenge

Natural language interfaces have made it easier to “talk to your data,” but turning a question into working SQL remains a surprisingly hard problem. Traditional Large Language Models (LLMs) often falter under real-world demands:

*   **Complex Relationships:** A query like *“total sales of eco-friendly products to customers in New York”* involves multiple tables (products, categories, orders, addresses). A single joining misstep leads to inaccurate results.
*   **Nested Logic:** Questions like *“Which employees earned more than the average salary?”* require multi-step reasoning (subqueries or CTEs) that models often miss.
*   **Language Ambiguity:** Terms like *“top-performing”* are subjective. The model must infer if this means revenue, profit, or ratings without explicit context.
*   **Messy Schemas:** Real-world databases often use opaque column names (`trn_val_01` vs `transaction_value`). Models must reason through this ambiguity to write valid SQL.

**In short, Text-to-SQL isn’t just a language task. It’s a reasoning problem over often-imperfect data.**

### The Solution

This demo solves these challenges using **Open WebUI Functions**—modular building blocks that extend WebUI capabilities without complex external integrations.

*   **Native Integration:** Functions run natively within the Open WebUI environment, ensuring speed and modularity.
*   **LlamaIndex Text-to-SQL:** By integrating LlamaIndex, the system leverages RAG (Retrieval-Augmented Generation) to understand the specific database schema and context before generating queries.
*   **Open Source:** The entire stack relies on open-source tools, frameworks, and models.

---

## Architecture

The solution is packaged entirely in Docker Compose, orchestrating the interaction between the User Interface, the AI Model, and the Database.

*(Place your architecture diagram here)*

---

## Prerequisites

Ensure your environment meets the following requirements:

*   **Ampere Altra / Altra Max System** (Recommended)
*   **Docker Engine** & **Docker Compose**

---

## Configuration

The application is pre-configured via the `.env` file. These settings define the database connection and the AI model endpoint.

**Default `.env` settings:**

```bash
DB_ENGINE=postgres
DB_HOST=host.docker.internal
DB_PORT=5435
DB_USER=postgres
DB_PASSWORD=dvdrental
DB_DATABASE=dvdrental
DB_TABLE=actor 
OLLAMA_HOST=http://host.docker.internal:11434
TEXT_TO_SQL_MODEL=hf.co/mradermacher/Arctic-Text2SQL-R1-7B-GGUF:Arctic-Text2SQL-R1-7B.Q8_0.gguf
```

## Quick Start
### Launch the Application
Use the provided helper script to build and start all services (Ollama, Database, Open WebUI).

```bash
./start-app.sh
```

### Stop the Application
To stop the services and clean up resources:
```bash
./stop-app.sh
```

## Usage

Once the application is running, access the interface via your web browser at 
```
http://<host-ip>:3000
```

### 1. Import the Function
There are three ways to import the required function:
#### 1.1 Import from community functions:
1.  Navigate to the function’s page on the Open WebUI community site: [Text to SQL RAG Pipe](https://openwebui.com/f/0xthresh/text_to_sql_rag_pipe).
2.  Click the blue **Get** button on the right-hand side.
3.  Click the **Import to WebUI** button. This will open a new tab in your local Open WebUI instance.
4.  In the new tab, click the **Save** button in the bottom-right corner, then click **Confirm** on the popup window.
5.  Once the format check is complete, you will be redirected back to the Functions page.

#### 1.2 Import from local file:
1. Click the **Import** button in the Functions interface.
2. Select the file from your local machine.
3. Click **Confirm**.

#### 1.3 Import from URL:
1. Click **New** Function.
2. Enter the URL.
3. Click **Import**, then **Save**, and finally **Confirm**.

*Note: You may have to refresh the page after import.*

> **Important:** Make sure to **enable** the model using the radio button/toggle on the right-hand side of the function entry. If this is not enabled, the model will not appear in your selection list.

### 2. Chat with Your Data
With the function imported and the required models pulled to Ollama, you can now retrieve data from the SQL database.

1.  Click the **New Chat** button in the top left.
2.  Select the **LlamaIndex Text to SQL RAG** model from the model dropdown.
3.  Send a message asking for data regarding the database table defined in your environment variables.

Here are 5 example prompts based on the PostgreSQL DVD Rental database that you can try:

**Prompt 1: Customer Search**
*   **Question:** "Find the email address for the customer named 'Nancy Thomas'."
*   **SQL Query (Generated):**
    ```sql
    SELECT email 
    FROM customer 
    WHERE first_name = 'Nancy' 
    AND last_name = 'Thomas';
    ```
*   **Expected Answer (when SQL query is run):** A single row containing the email address.
*   **Result:** `nancy.thomas@sakilacustomer.org`

**Prompt 2: Filtering Films by Rating**
*   **Question:** "List the titles of all films that have a 'G' rating."
*   **SQL Query (Generated):**
    ```sql
    SELECT title 
    FROM film 
    WHERE rating = 'G';
    ```
*   **Expected Answer (when SQL query is run):** A list of film titles where the rating column equals 'G'.
*   **Result:** (Returns approx 178 rows) *ACE GOLDFINGER, ALAMO VIDEOTAPE, AMISTAD MIDSUMMER, etc.*

**Prompt 3: Aggregating Inventory Data**
*   **Question:** "How many total distinct films are currently listed in the inventory?"
*   **SQL Query (Generated):**
    ```sql
    SELECT COUNT(DISTINCT film_id) 
    FROM inventory;
    ```
*   **Expected Answer (when SQL query is run):** A single integer representing the number of unique movies available in physical inventory.
*   **Result:** `958` *(Note: While there are 1000 films in the film table, only 958 are physically in the inventory table).*

**Prompt 4: Sorting and Limiting Results**
*   **Question:** "What are the top 5 longest films by duration?"
*   **SQL Query (Generated):**
    ```sql
    SELECT title, length 
    FROM film 
    ORDER BY length DESC 
    LIMIT 5;
    ```
*   **Expected Answer (when SQL query is run):** A table with the titles and lengths of the 5 longest movies.
*   **Result:**
    *   DARN FORRESTER (185)
    *   POND FLOYD (185)
    *   CHICAGO NORTH (185)
    *   MUSCLE BRIGHT (185)
    *   WORST BANGER (185)

**Prompt 5: Calculating Revenue**
*   **Question:** "Calculate the total revenue generated from all payments made by customers."
*   **SQL Query (Generated):**
    ```sql
    SELECT SUM(amount) 
    FROM payment;
    ```
*   **Expected Answer (when SQL query is run):** A single numeric value representing the sum of the amount column in the payment table.
*   **Result:** `61312.04`

### 3. Refining Results
To improve the Text-to-SQL capabilities, you should experiment with the system prompts:

1.  Go to the **Admin Settings** panel within Open WebUI.
2.  Edit the function directly to include specific examples.
3.  Add between **5 and 10 examples** of common questions real users might ask, along with the relevant SQL columns or queries used to answer them.

*Providing clear examples helps the model understand the specific context and nuances of your database schema.*


### License
This project is licensed under the MIT License. See the LICENSE file for details.
