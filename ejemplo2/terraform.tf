resource "local_file" "productos" {
    content = "Lista de productos para el mes que viene."
    filename = "productos.txt"
}


resource "local_file" "clientes" {
    content = "Lista de clientes para el mes que viene."
    filename = "clientes.txt"
}