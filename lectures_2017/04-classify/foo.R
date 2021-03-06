n = 50
y = c(rep(1,n/2),rep(2,n/2))

set.seed(0)
x = c(runif(n/2,0,0.35),
  runif(n/2,0.7,1))
r = lm(y~x)
a = r$coefficients[1]
b = r$coefficients[2]
v = (1.5-a)/b
m = sum(x[y==1]>v) + sum(x[y==2]<=v)

pdf(file="lin1.pdf",height=4.5,width=4.5)
par(mar=c(4.5,4.5,2,2))
plot(x,y,main=sprintf("%i mistakes",m))
abline(a=a,b=b,lty=2)
abline(v=v,col="red")
graphics.off()

set.seed(0)
x = c(runif(n/2,0,0.575),
  runif(n/2,0.525,1))
r = lm(y~x)
a = r$coefficients[1]
b = r$coefficients[2]
v = (1.5-a)/b
m = sum(x[y==1]>v) + sum(x[y==2]<=v)

pdf(file="lin2.pdf",height=4.5,width=4.5)
par(mar=c(4.5,4.5,2,2))
plot(x,y,main=sprintf("%i mistakes",m))
abline(a=a,b=b,lty=2)
abline(v=v,col="red")
graphics.off()

z = y-1
r2 = glm(z~x,family="binomial")
xx = seq(0,1,length=500)
a2 = r2$coefficients[1]
b2 = r2$coefficients[2]
fx = 1/(1+exp(-a2-b2*xx))

pdf(file="logr.pdf",height=5,width=5)
par(mar=c(4.5,4.5,0.5,0.5))
plot(x,z,ylab="y")
lines(xx,fx,lty=2)
abline(v=-a2/b2,col="red")
graphics.off()

set.seed(0)
x = c(runif(13,0,0.5),runif(12,1,1.5),
  runif(25,0.6,1))
r = lm(y~x)
a = r$coefficients[1]
b = r$coefficients[2]
v = (1.5-a)/b
m = sum(x[y==1]>v) + sum(x[y==2]<=v)

pdf(file="lin3.pdf",height=4.5,width=4.5)
par(mar=c(4.5,4.5,2,2))
plot(x,y,main=sprintf("%i mistakes",m))
abline(a=a,b=b,lty=2)
abline(v=v,col="red")
graphics.off()

z = y-1
r2 = glm(z~x,family="binomial")
xx = seq(-20,20,length=500)
a2 = r2$coefficients[1]
b2 = r2$coefficients[2]
fx = 1/(1+exp(-a2-b2*xx))

par(mar=c(4.5,4.5,0.5,0.5))
plot(x,z,ylab="y")
lines(xx,fx,lty=2)
abline(v=-a2/b2,col="red")


###### olive oil

library(classifly)
data(olives)

y = as.numeric(olives[,1])
x = as.matrix(olives[,3:10])

n = nrow(x)
p = ncol(x)

pi = numeric(3)
mu = matrix(0,3,8)

for (j in 1:3) {
  pi[j] = sum(y==j)/n
  mu[j,] = colMeans(x[y==j,])
}

Sigma = matrix(0,p,p)
for (j in 1:3) {
  A = scale(x[y==j,],center=T,scale=F)
  Sigma = Sigma + t(A)%*%A
}
Sigma = Sigma/(n-3)
Sigmainv = solve(Sigma)

lda.classify = function(x0, pi, mu, Sigmainv) {
  K = length(pi)
  delta = numeric(K)
  for (j in 1:K) {
    delta[j] = t(x0) %*% Sigmainv %*% mu[j,] -
      0.5 * t(mu[j,]) %*% Sigmainv %*% mu[j,] + log(pi[j])
  }
  return(which.max(delta))
}

yhat = numeric(n)
for (i in 1:n) {
  yhat[i] = lda.classify(x[i,],pi,mu,Sigmainv)
}

# Training errors
sum(yhat!=y)

# Still left with some questions ...

# How would we visualize the LDA classification rule /
# the decision boundaries here, since p=8?

library(MASS)
a = lda(x,y)
cols = c("red","darkgreen","blue")
z = x %*% a$scaling # What are these "scalings"?

pdf(file="lda.pdf",height=5,width=5)
par(mar=c(4.5,4.5,0.5,0.5))
plot(z,col=cols[y]) # What is this showing?
graphics.off()

dim(olives)
colnames(olives)

as.indmat = function(z) {
  z = as.factor(z)
  l = levels(z)
  b = as.numeric(z==rep(l,each=length(z)))
  return(matrix(b,length(z)))
}

y = as.indmat(olives[,1])
x = as.matrix(olives[,3:10])

cc = cancor(x,y,ycenter=F)
alpha = cc$xcoef
beta = cc$ycoef

alpha[,1:2]*1e4
beta[,1:2]

xvars = x %*% alpha
yvars = y %*% beta


cols = c("red","darkgreen","blue")
par(mar=c(4.5,4.5,0.5,0.5))

plot(xvars[,1:2],col=cols[olives[,1]],
xlab="First canonical x variate",
ylab="Second canonical x variate")

legend("bottomleft",pch=21,col=cols,
legend=c("Region 1","Region 2","Region 3"))

