from julia_client import julia_client

def on_commit(message):
    print('on_commit sending message: ', message)
    res = julia_client.send(message)
    print('on_commit received response: ', res)
