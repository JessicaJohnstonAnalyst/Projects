import requests

def create_access_token(client_id, client_secret, region='us'):
    data = {'grant_type': 'client_credentials'}
    response = requests.post(f'https://{region}.battle.net/oauth/token', data=data, auth=(client_id, client_secret))
    return response.json()

def get_price(access_token, region='us'):
    headers = {'Authorization': f'Bearer {access_token}'}
    response = requests.get(f'https://{region}.api.blizzard.com/data/wow/token/?namespace=dynamic-us', headers=headers)
    return response.json()

# Store the access token
access_data = create_access_token("[[CLIENT_ID FROM BLIZZARD]]", "[[SECRET_ID FROM BLIZZARD]]")
access_token = access_data.get('access_token')

# Use the access token to get the price
price_data = get_price(access_token)
print(price_data)
price = price_data.get('price', 'No price found')

# Now we add to the Google Sheet
import gspread
from oauth2client.service_account import ServiceAccountCredentials

# Define the scope and create the credentials
scope = ["https://spreadsheets.google.com/feeds", "https://www.googleapis.com/auth/drive"]
creds = ServiceAccountCredentials.from_json_keyfile_name(r"[[FULL JSON FILE PATH]]", scope)
client = gspread.authorize(creds)

# Open the Google Sheet
spreadsheet = client.open("[[GOOGLE SPREADSHEET NAME]]")
sheet = spreadsheet.worksheet("[[GOOGLE SPREADSHEET TAB NAME]]")

# Write to First blank In desired column (A=1, B=2, ....).  Default set to Column C (3) as an example.
col_c = sheet.col_values(1)

# Next empty row in Column Q
next_row = len(col_c) + 1

# Write the price
sheet.update_acell(f'Q{next_row}', price)