resource "local_file" "productos" {
    count = 5
    content = "Lista de productos para el mes que viene."
    filename = "productos-${random_string.sufijo[count.index].id}.txt"
}


