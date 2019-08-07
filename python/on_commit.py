from julia_client import julia_client
import pandas as pd
import json

def on_commit(data):
    print('on_commit sending...')
    res = julia_client.send_data(data)
    branch_results = json.loads(str(res)[2:-1])
    results = pd.DataFrame(branch_results['columns'],index=branch_results["colindex"]['names']).transpose()
    print('* * * back to python * * * \non_commit received islanding results: \n', results)
