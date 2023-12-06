constants = import_module("../utils/constants.star")

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

    bootnode = bootnode_enrs.split(",")[0]
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
            entrypoint = [
                "fluffy",
                "--rpc",
                "--rpc-address=0.0.0.0",
                "--nat:extip:{}".format(constants.PRIVATE_IP_ADDRESS_PLACEHOLDER),
                # multiple bootnodes?
                "--bootstrap-node:{}".format(bootnode)
            ],
        ),
    )

    return fluffy
