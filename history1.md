# Historia del deploy
--- Hecho

1. Usar vm's
2. Usar docker
3. Usar k8s en las máquinas remotas
4. Usar cardano-cli para registrar el staking pool
5. Crear un sistema de métricas y alertas con prometheus/grafana
6. Usar el explorador pooltool, y otras herramientas de la comunidad para ver cómo es la mejor forma en que se puede ganar con él
--- Por hacerse
7. Crear un certificado de seguridad ssl para entrar con https a la ui de grafana
8. Cambiar a mainnet
9. Usar webiny para la delegación

## Esencia:

El problema en esencia, es el de montar un staking pool. Una topología que permita a los usuarios de cardano delegar sus ADA, en esta, para poder formar parte del POS (Proof of Stake) de la red. Usar webiny para clear la ui en que se hace la delegación.


## Consideraciones:

1. Usamos 3 vm con ubuntu 20.04 y 30 GB de espacio, y una con ubuntu 18.04 y 10 GB. Arquitectura arm64. La topología está compuesta por dos cardano-node, tipo relay, y un cardano-node, tipo producer. Cada cardano-node como proceso, corre en una de las tres vm de 30 GB de espacio.
2. Para montar un cardano-node en docker, usamos la imagen [siguiente](https://hub.docker.com/layers/nessusio/cardano-node/dev/images/sha256-54d5b1dbe9f9bb06a7a68f21b75525e524107871f8d70bc3e06934b6360a00fb?context=explore) compatible con la arquitectura de las máquinas virtuales (que son en sí los nodos del clúster de k8s).
3. La ventaja de usar k8s es que permite moverse siempre hacia el estado correcto del cluster de forma automática. Cuando hay algún problema, se detienen los recursos con el problema y eso se puede inspeccionar. Así mismo cualquier cambio en la configuración del clúster puede ser actualizado, y se pueden reiniciar los recursos, y actualizar dichos cambios. K8s permite definir un clúster entre las 4 vm's, considerando a cada una como un nodo de este clúster, y luego a partir de manifiestos en formato `.yaml` escoger cómo los recursos, dígase el almacenamiento que necesita cada cardano-node, los cardano-node como procesos, etc., serán distribuidos y ejecutados en dichos nodos. Para los detalles en las configuraciones puede verse la carpeta compose en el repo.
4. Para usar cardano-cli y registrar el staking pool en la testnet seguimos [estos](https://docs.cardano.org/getting-started/operating-a-stake-pool/about-stake-pools) pasos. El nodo puede verse [acá](https://testnet.adatools.io/pools/0f9096930666d7c36f8b53577c84a3e92d0867be616132f0998e097b). La configuración de testnet que seguimos es la oficial.
5. Para el sistema de métricas, se añadió prometheus al cluster usando [helm](https://helm.sh/), un gestor de paquetes de k8s.

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus-monitoring prometheus-community/kube-prometheus-stack --namespace monitoring
```

Las ui de las métricas se exporta hacia el exterior usando un servicio de k8s de tipo NodePort. Queda por hacer montar un servicio ingress con https para acceder a esta ui con una mejor seguridad. Y además, programar alertas.
6. Se han presentado algunos issues usando las herramientas de exploración para ver el nodo. Por una parte, lo actualizé, y puede verse la nueva url con los datos haciendo esta query:
`cardano-cli query pool-params --stake-pool-id 0f9096930666d7c36f8b53577c84a3e92d0867be616132f0998e097b --testnet-magic 1097911063`
Pero en la url que señalé antes no se ven los cambios.
Por otra parte, en [pooltool](https://pooltool.io/) en modo testnet no [encuentro el id de la staking pool](https://forum.cardano.org/t/how-to-check-staking-pool-on-testnet-explorer/59807/6?u=diazrock).
He intentado también añadir [cncli](https://github.com/AndrewWestberg/cncli), una herramienta de la comunidad que permite hacer consultas sobre el estado del staking pool.



## Queda por hacer

Queda mover el sistema a la red donde están los activos con valor real. O sea, la mainnet. Queda también crear la interfaz gráfica con webiny. Y una vez, definido el sistema correctamente, queda el viaje de mantenerlo (cuidar que los recursos como los pods que maneja cada nodo estén activos, buscar inversores/delegadores de ADA) y que sea parte del concenso.