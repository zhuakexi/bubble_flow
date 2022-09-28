# global variables
# samples
sample_table = pd.read_csv(config["sample_table"], dtype={0:pd.StringDtype()},index_col=0)
# dirs
ana_home = config["ana_home"] # home directory of all analysis results
rd = os.path.join(ana_home,"rd") # dir to store stat jsons
# softwares
hires = config["software"]["hires"]
hickit = config["software"]["hickit"]
k8 = config["software"]["k8"]
js = config["software"]["js"]