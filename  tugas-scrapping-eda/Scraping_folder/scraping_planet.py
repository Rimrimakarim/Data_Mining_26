import requests
import pandas as pd
import io

url = "https://exoplanetarchive.ipac.caltech.edu/TAP/sync"
que = "SELECT * FROM pscomppars"
params = {
    "query" : que,
    "format" : "csv"
}
print("mulai mengunduh..")
response = requests.get(url, params=params)

if response.status_code == 200 :
    df = pd.read_csv(io.StringIO(response.text, low_memory=False))
    df.to_csv("data.csv", index=False)

    print("pengumpulan selesai dengan hasil {df.shape[0]} planet dengan {df.shape[1]} kolom/fitur.")
else: 
    print("gagal pengambilan, error {response.status_code}")
    print(response.text)