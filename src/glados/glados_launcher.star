constants = import_module("../utils/constants.star")
postgres = import_module("github.com/kurtosis-tech/postgres-package/main.star")


# The min/max CPU/memory that postgres can use
POSTGRES_MIN_CPU = 10
POSTGRES_MAX_CPU = 1000
POSTGRES_MIN_MEMORY = 32
POSTGRES_MAX_MEMORY = 1024

GLADOS_MIN_CPU = 0
GLADOS_MAX_CPU = 5000
GLADOS_MIN_MEMORY = 32
GLADOS_MAX_MEMORY = 2048

def launch(
    plan,
    bootnode_enrs,
):
    postgres_output = postgres.run(
        plan,
        service_name="glados-postgres",
        min_cpu=POSTGRES_MIN_CPU,
        max_cpu=POSTGRES_MAX_CPU,
        min_memory=POSTGRES_MIN_MEMORY,
        max_memory=POSTGRES_MAX_MEMORY,
        persistent=False,
    )

    trin = plan.add_service(
        name = "glados-trin",
        config = ServiceConfig(
            image = "portalnetwork/trin:latest",
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
            # move to constants
            max_cpu = 1000,
            min_cpu = 0,
            max_memory = 1000,
            min_memory = 0,
            env_vars = {
                "RUST_LOG": "info",
            },
            entrypoint = [
                "/usr/bin/trin",
                "--bootnodes={}".format(bootnode_enrs),
                "--web3-transport=http",
                "--web3-http-address=http://0.0.0.0:8545/",
                "--external-address={}:9009".format(constants.PRIVATE_IP_ADDRESS_PLACEHOLDER),
                "--disable-poke",
                "--mb=0"
            ],
        ),
    )
    
    glados_audit = plan.add_service(
        name = "glados-audit",
        config = ServiceConfig(
            image = "portalnetwork/glados-audit:latest",
            private_ip_address_placeholder = constants.PRIVATE_IP_ADDRESS_PLACEHOLDER,
            max_cpu = GLADOS_MAX_CPU,
            min_cpu = GLADOS_MIN_CPU,
            max_memory = GLADOS_MAX_MEMORY,
            min_memory = GLADOS_MIN_MEMORY,
            env_vars = {
                "RUST_LOG": "warn,glados_audit=info",
            },
            entrypoint = [
                "/usr/bin/glados-audit",
                 "--database-url={}".format(postgres_output.url),
                 "--portal-client=http://{}:8545".format(trin.ip_address),
                 "--concurrency=2",
            ],
        ),
    )

    secrets = read_file("../../.secrets.json")
    secrets = json.decode(secrets)

    glados_monitor = plan.add_service(
        name = "glados-monitor",
        config = ServiceConfig(
            image = "portalnetwork/glados-monitor:latest",
            max_cpu = GLADOS_MAX_CPU,
            min_cpu = GLADOS_MIN_CPU,
            max_memory = GLADOS_MAX_MEMORY,
            min_memory = GLADOS_MIN_MEMORY,
            private_ip_address_placeholder = constants.PRIVATE_IP_ADDRESS_PLACEHOLDER,
            env_vars = {
                "RUST_LOG": "warn,glados_monitor=info",
            },
            entrypoint = [
                "/usr/bin/glados-monitor",
                "--database-url={}".format(postgres_output.url),
                "follow-head",
                "--provider-url=https://mainnet.infura.io/v3/{}".format(secrets["TRIN_INFURA_PROJECT_ID"])
            ],
        ),
    )


    glados_web = plan.add_service(
        name = "glados-web",
        config = ServiceConfig(
            image = "portalnetwork/glados-web:latest",
            ports = {
                "http": PortSpec(
                    number = 3001,
                    application_protocol = "http",
                    wait = "15s"
                ),
            },
            private_ip_address_placeholder = constants.PRIVATE_IP_ADDRESS_PLACEHOLDER,
            max_cpu = GLADOS_MAX_CPU,
            min_cpu = GLADOS_MIN_CPU,
            max_memory = GLADOS_MAX_MEMORY,
            min_memory = GLADOS_MIN_MEMORY,
            env_vars = {
                "RUST_LOG": "warn,glados_web=info",
            },
            entrypoint = [
                "/usr/bin/glados-web",
                "--database-url={}".format(postgres_output.url),
            ],
        ),
    )


    glados_cartographer = plan.add_service(
        name = "glados-cartographer",
        config = ServiceConfig(
            image = "portalnetwork/glados-cartographer:latest",
            private_ip_address_placeholder = constants.PRIVATE_IP_ADDRESS_PLACEHOLDER,
            max_cpu = GLADOS_MAX_CPU,
            min_cpu = GLADOS_MIN_CPU,
            max_memory = GLADOS_MAX_MEMORY,
            min_memory = GLADOS_MIN_MEMORY,
            env_vars = {
                "RUST_LOG": "warn,glados_audit=info",
            },
            entrypoint = [
                "/usr/bin/glados-cartographer",
                "--database-url={}".format(postgres_output.url),
                "--transport=http",
                "--http-url=http://{}:8545".format(trin.ip_address),
                "--concurrency=10",
            ],
        ),
    )
    return glados_web
