import json
import pandas as pd

def convert(list):
    # Converting integer list to string list
    # and joining the list using join()
    res = " ".join(map(str, list))
    return res

def process_payload(load_file):
    '''
    reads in json file, from gridlabd and returns dict of necessary data for virtual_islanding.jl optimization
        args: `load_file`:: str = json file location
    '''
    if load_file[-4:]=='json':
        with open(load_file) as f:
            json_data = json.load(f)

        switchstat = {'CLOSED':1,'OPEN':0}
        genstat = {'OFFLINE':0,'ONLINE':1}
        branchdata = {}
        gendata = {}
        shuntdata = {}
        meter2bus = {}
        for obj_name in json_data['objects']:
            obj = json_data['objects'][obj_name]
            bid = obj['id']
            # get branches/links
            if obj['class']=='overhead_line':
                branchdata[bid]={}
                branchdata[bid]['t'] = obj['to'].split('_')[1][:3]
                branchdata[bid]['f'] = obj['from'].split('_')[1][:3]
                branchdata[bid]['status'] = switchstat[obj['status']]
                branchdata[bid]['kind'] = 'fixed'
                line = obj
            elif obj['class']=='underground_line':
                branchdata[bid]={}
                branchdata[bid]['t'] = obj['to'].split('_')[1][:3]
                branchdata[bid]['f'] = obj['from'].split('_')[1][:3]
                branchdata[bid]['status'] = switchstat[obj['status']]
                branchdata[bid]['kind'] = 'fixed'
                line = obj
            elif obj['class']=='switch':
                branchdata[bid]={}
                branchdata[bid]['t'] = obj['to'].split('_')[1][:3]
                branchdata[bid]['f'] = obj['from'].split('_')[1][:3]
                branchdata[bid]['status'] = switchstat[obj['status']]
                branchdata[bid]['kind'] = 'switch'
                switch = obj
            # get generators (solar/batteries)
            elif obj['class']=='solar':
                gendata[bid] = {}
                gendata[bid]['bus'] = obj['parent'].split('_')[1]
                gendata[bid]['P'] = float(obj['P_Out'].strip('kW').split('+')[1])/1000 #P_Out in kW
                gendata[bid]['Pmin'] = 0
                gendata[bid]['Pmax'] = float(obj['rated_power'].strip('W'))/1000000 #rated_power in W
                gendata[bid]['status'] = genstat[obj['generator_status']]
                solar = obj
            #ignore batteries for now
            #elif obj['class']=='battery':
            #    gendata[bid] = {}
            #    gendata[bid]['bus'] = obj['parent'].split('_')[1]
            #    gendata[bid]['P'] = obj['P_max']
            #    gendata[bid]['Pmin'] = 0
            #    gendata[bid]['Pmax'] = float(obj['rated_power'].strip('W'))/1000000 #rated_power in W
            #    gendata[bid]['status'] = genstat[obj['generator_status']]
            #    battery = obj

            elif obj['class']=='node':
                #print('node: ',bid)
                try:
                    if obj['parent']=='':
                        node = obj
                        #print(obj_name,obj)
                except:
                    pass
                pass
            # get shunts/loads
            elif obj['class']=='house':
                shuntdata[obj['parent'].split('_')[1]] = {}
                meter = json_data['objects'][obj['parent']]
                shuntdata[obj['parent'].split('_')[1]]['bus'] = obj['supernode_name'].split('_')[1]
                shuntdata[obj['parent'].split('_')[1]]['P'] = float(meter['measured_real_power'].strip('W'))/1000000 #measured_real_power in W

        gen_df = pd.DataFrame(gendata).transpose()
        shunt_df = pd.DataFrame(shuntdata).transpose()
        branch_df = pd.DataFrame(branchdata).transpose()
        branch_df = branch_df.loc[branch_df.t!=branch_df.f,:]
        branch_df['X'] = 0.1
        branch_df['R'] = 0
        branch_df['id'] = branch_df.index

    else:
        # load_file = location of all dataframes branch.csv,gen.csv,shunt.csv
        branch_df = pd.read_csv(load_file+'branch.csv')
        gen_df = pd.read_csv(load_file+'gen.csv')
        shunt_df = pd.read_csv(load_file+'shunt.csv')

    buses = set(list(branch_df.t)+list(branch_df.f))
    nbus = len(buses)
    busids = list(range(1,nbus+1))
    busmap = {b:i for i,b in zip(busids,sorted(list(buses)))}

    branch_df.t = [busmap[t] for t in branch_df.t]
    branch_df.f = [busmap[f] for f in branch_df.f]
    gen_df.bus = [busmap[f] for f in gen_df.bus]
    shunt_df.bus  = [busmap[f] for f in shunt_df.bus]

    datadump = {}
    for c in ['id','t','f','R','X','status','kind']:
        datadump['branch_'+c] = convert(list(branch_df[c]))
    for c in ['bus','P','Pmin','Pmax','status']:
        datadump['gen_'+c] = convert(list(gen_df[c]))
    for c in ['bus','P']:
        datadump['shunt_'+c] = convert(list(shunt_df[c]))

    return datadump
