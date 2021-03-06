############################################
## Script desenvolvido por �caro Agostino ##
##### Email: icaroagostino@gmail.com #######
############################################

#Julho/2018

rm(list=ls()) #Limpando a memoria

########################
# chamando bibliotecas #
########################

# caso n�o tenha instalado as bibliotecas abaixo use o comando:
# install.packages('nome da biblioteca')

library(tseries) #Manipular ST (Trapletti and Hornik, 2017)
library(TSA) #Manipular ST (Chan and Ripley, 2012)
library(lmtest) #Test. Hip. mod. lin. (Zeileis and Hothorn, 2002)
library(forecast) #Modelos de previs�o (Hyndman and Khandakar, 2008)
library(ggplot2) #Elegant Graphics (Wickham, 2009)
#library(ggfortify) #Manipular graf. (ST) (Horikoshi and Tang, 2016)

# Obs.: a biblioteca 'ggfortify' � opcional, ela permite
# manipular melhor 'autoplot' para dados tipo ST.

########################
### Importando dados ###
########################

# para este exemplo vamos importar um banco direto da internet
# que est� hospedado em https://github.com/icaroagostino/ARIMA
# s�o dados mensais do saldo de emprego do estado do Maranh�o

dados <- read.table("https://raw.githubusercontent.com/icaroagostino/ARIMA/master/dados/MA.txt", header=T) #lendo banco
attach(dados) #tranformando em objeto

# precisamos tranformar os dados em ST utilizando o comando 'ts'
# o primeiro argumento da fun��o � o nome da vari�vel no banco

MA <- ts(MA, start = 2007, frequency = 12) #tranformando em ST

# start = data da primeira observa��o
# frequency = 1  (anual)
# frequency = 4  (trimestral)
# frequency = 12 (mensal)
# frequency = 52 (semanal)

# caso queira importar direto do pc voc� precisa definir o 
# diret�rio onde est�o os dados, uma forma simples � usar
# o atalho "Ctrl + Shift + H" ou atrav�s do comando abaixo

# setwd(choose.dir())

# a formato mais simples para importar dados � o txt,
# substitua o nome do arquivo no comando read.table 
# mantendo a exten��o ".txt"

############################
## Etapa 1: Identifica��o ##
############################

# Inspe��o visual

autoplot(MA) + xlab("Anos") + ylab("Saldo de emprego - MA")

# verifica��o da autocorrela�ao (acf)
# e aucorrela�ao parical (pacf)

ggtsdisplay(MA) #ST + acf + pacf
ggAcf(MA) #fun��o de autocorrela��o
ggPacf(MA) #fun��o de autocorrela��o parcial

########################
## Etapa 2: Estima��o ##
########################

# para a estima��o dos parametros e ajuste do modelo
# ser� utilizado a fun��o nnetar(), que utiliza o algoritimo
# baseado na fun��o nnet() desenvolvido e publicado por
# Venables e Ripley (2002). Est� abordagem somente considera
# a arquitertura feed-forward networks com uma camada
# intermedi�ria usando a nota��o NNAR(p,k) para s�ries sem
# sazonalidade e NNAR(p,P,k)[m] para s�ries com sazonalidade
# sendo que 'p' representa o n�mero de lags na camada de 
# entrada, 'k' o n�mero de n�s na camada intermedi�ria da
# rede, P � n�mero de lags sazonais e [m] a ordem sazonal

NNAR_fit <- nnetar(MA)
NNAR_fit #sai o modelo ajustado

# Estima��o manual NNAR(p,P,k)[m]

# NNAR_fit_manual <- nnetar(MA, p = 1, P = 1, size = 1)

# Obs: informe os par�metros a serem estimados, o primeiro 
# argumento � a TS, seguido do n�mero de p lags defasados,
# o n�mero P lags sazonais, o n�mero de k n�s na camada
# intermadi�ria, tamb�m � poss�vel definir o n�mero de
# repeti��es para o ajuste do modelo adicionando o argumento
# 'repeats = 20', o que acarretar� em um provav�l aumento 
# da acur�cia, mas tamb�m exigira maior tempo para o ajuste 
# da rede caso repeats > 20

###################################################
## Etapa 3: Valida��o (Verifica��o dos residuos) ##
###################################################

# Verificar se os residuos s�o independentes (MA)

checkresiduals(forecast(NNAR_fit))

# Verificar os residuos padronizados (MA)

Std_res <- (resid(NNAR_fit) - mean(resid(NNAR_fit), na.rm = T)) / sd(resid(NNAR_fit), na.rm = T)

autoplot(Std_res) +
  geom_hline(yintercept = 2, lty=3) +
  geom_hline(yintercept = -2, lty=3) +
  geom_hline(yintercept = 3, lty=2, col="4") +
  geom_hline(yintercept = -3, lty=2, col="4")

#######################
## Etapa 4: previs�o ##
#######################

# Nessa etapa � definido o horizonte de previs�o (h)

print(forecast(NNAR_fit, h = 12, PI = T))
autoplot(forecast(NNAR_fit, h = 12, PI = T))
accuracy(forecast(NNAR_fit)) #periodo de treino

# Obs.: a inclus�o do intervalo de confian�a aumenta
# consideravelmente o tempo de processamento, caso queira
# retirar basta mudar o argumento para 'PI = F'

# Como refer�ncia para maiores detalhes sobre diversos 
# aspesctos relacionados a previs�o fica como sugest�o
# o livro 'Forecast principles and practice' (Hyndman e 
# Athanasopoulos, 2018) o primeiro autor do livro � 
# tamb�m criador do pacote 'forecast' utilizado neste
# script e o livro pode ser lido online gratuitamente
# em: https://otexts.org/fpp2/index.html

# Para maiores detalhes sobre aplica��es de RNA em 
# linguagem R consulte a biblioteca 'nnet', desenvolvida
# por Venables e Ripley (2002), com a ultima vers�o 7.3
# de 2016 e para aplica��es mais avan�adas o pacote
# 'RSNNS', desenvolvida por Bergmeir e Benitez (2012),
# com a ultima vers�o 0.4 de 2017

# para referenciar as bibliotecas use o comando:
# citation('nome da biblioteca')