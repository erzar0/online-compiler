resource "helm_release" "nginx_ingress-controller" {
  name = "nginx-ingress-controller"

  repository       = "oci://registry-1.docker.io/bitnamicharts"
  chart            = "nginx-ingress-controller"
  version          = "11.5.5"
  namespace        = "ingress-nginx-controller"
  create_namespace = true
  values = [ file("${path.module}/values.yaml") ]


  set {
    name  = "service.type"
    value = "ClusterIP"
  }
}
