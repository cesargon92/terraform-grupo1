# terraform-grupo1
## tarea de terraform del grupo 1 mjs del diplomado de devops

1.- iniciar terraform en el repositorio clonado en local:
    os> terraform init    

2.- generar recursos en azure mediante script terraform 
    os> terraform plan
    os> terraform apply
    os> para confirmar terraform apply ingresar 'yes'

3.- obtener credenciales de la máquina virtual creada:
    si el resultado de terraform apply es ok, la consola mostrará la ip, usuario y password de la VM, las que deben ser indicadas en el script inventario.

4.- copiar la llave ssh para ek usuario adminuser:
    os> ssh-copy-id adminuser@(ip_maquina_virtual_creada)

5.- ejecutar ansible:
    os> ansible-playbook -i inventario jenkins.yml