# eyJhbGciOiJSUzI1NiIsImtpZCI6ImNSZTBHM1phbzRXQzhwa1hIY3ZtTzJYWWlsdVhlTGgzbHp3TmdYNDJ1Y3MifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi11c2VyIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImFkbWluLXVzZXIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiIxZjI4MjU4ZS02ODQzLTQ3YTUtYmE2ZC00ZDQzMTEzZjZlMmQiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZXJuZXRlcy1kYXNoYm9hcmQ6YWRtaW4tdXNlciJ9.a9EWWBJdOqupSKNyjZQ1DIvpzlt0moCxkG0ucvzl3gWNnB3pp54zaatkCDlmyzRtFq0Sn5o6ivZ_Y7n_gYhDtbEz8-U3LiP3Z0v4A1MsaF_WwdJ14rXuj8IOKJEHDxMuKeihQ32JNtwFMq02I2sJYvV7XWa2Dfp8KfD0-Is0zq8TADj_Exhh7vRT-jcRPZ8hBQiR01Kb1GCffy8_DXNbRiw-RrFGAUMltOlx0rlSjM2kakddxnGSNV3ut1J-KFye1PMvJNGV1jeeBpLk3NI5mMh3HAhjjaejwr1Z_4Eg44vdue4lYblznQMiEaWa4Q9SshaTiuIQAo0oxj0S5l3M7Q

d9z0Yvujh5vJoWyTAC

apiVersion: v1
kind: PersistentVolume
metadata:
  name: word-pv-volume
  labels:
    app: wordpress
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/nota"


apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv-volume
  labels:
    app: wordpress
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/tata"

