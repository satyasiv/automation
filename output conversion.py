from bs4 import BeautifulSoup

# Specify the path to your log.html file
log_html_path = 'path/to/your/log.html'

# Read the content of the log.html file
with open(log_html_path, 'r', encoding='utf-8') as html_file:
    html_content = html_file.read()

# Parse the HTML content using BeautifulSoup
soup = BeautifulSoup(html_content, 'html.parser')

# Extract the text content from the HTML
text_content = soup.get_text()

# Specify the path for the output text file
output_text_path = 'path/to/your/output.txt'

# Write the text content to the output text file
with open(output_text_path, 'w', encoding='utf-8') as text_file:
    text_file.write(text_content)

print(f'Text content has been saved to {output_text_path}')
