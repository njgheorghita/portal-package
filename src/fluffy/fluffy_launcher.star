constants = import_module("../utils/constants.star")
client_context = import_module("../utils/client_context.star")

def launch(
    plan,
    service_name,
    image,
    private_key,
    min_cpu,
    max_cpu,
    min_mem,
    max_mem,
    bootnode_enrs,
):

    entrypoint = [
        "fluffy",
        "--rpc",
        "--rpc-address=0.0.0.0",
        "--network=none",
        "--nat:extip:{}".format(constants.PRIVATE_IP_ADDRESS_PLACEHOLDER),
    ]

    if bootnode_enrs != "none":
        # multiple bootnodes?
        bootnode = bootnode_enrs.split(",")[0]
        bootnode = "--bootstrap-node:{}".format(bootnode)
        entrypoint.append(bootnode)

    fluffy = plan.add_service(
       name = service_name,
       config =  ServiceConfig(
            image = image,
            ports = {
                "http": PortSpec(
                    number = 8545,
                    application_protocol = "http",
                    wait = "15s"
                ),
            },
            min_cpu = min_cpu,
            max_cpu = max_cpu,
            min_memory = min_mem,
            max_memory = max_mem,
            private_ip_address_placeholder = constants.PRIVATE_IP_ADDRESS_PLACEHOLDER,
            entrypoint = entrypoint,
        ),
    )

    return client_context.new_client_context(
        constants.CLIENT_TYPE.fluffy,
        fluffy.ip_address,
        8545,
        service_name,
        None, # metrics info - not yet supported for fluffy
    )
