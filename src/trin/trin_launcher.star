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
    trin = plan.add_service(
        name = service_name,
        config = ServiceConfig(
            image = image,
            ports = {
                "http": PortSpec(
                    number = 8545,
                    application_protocol = "http",
                    wait = "15s"
                ),
                "utp": PortSpec(
                    number = 9009,
                    transport_protocol = "UDP",
                    wait = "15s"
                )
            },
            private_ip_address_placeholder = constants.PRIVATE_IP_ADDRESS_PLACEHOLDER,
            max_cpu = max_cpu,
            min_cpu = min_cpu,
            max_memory = max_mem,
            min_memory = min_mem,
			entrypoint = [
				"/usr/bin/trin",
                "--bootnodes={}".format(bootnode_enrs),
                "--web3-transport=http",
                "--web3-http-address=http://0.0.0.0:8545",
                "--external-address={}:9009".format(constants.PRIVATE_IP_ADDRESS_PLACEHOLDER),
			],
        ),
    )

    return trin
