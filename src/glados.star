constants = import_module("./utils/constants.star")
glados = import_module("./glados/glados_launcher.star")

def launch(
    plan,
    bootnode_enrs,
):
    context = glados.launch(
        plan,
        bootnode_enrs
    )
    return context
