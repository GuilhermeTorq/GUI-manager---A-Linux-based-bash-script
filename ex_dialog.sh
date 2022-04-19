#!/bin/sh
#Menu de opções de multiplas ou uma única escolha

# Trabalho:
# a - completo
# b - completo
# c - completo
# d - completo
# e - completo
# f - completo

# Ficheiros que fazem parte do script:
# Pasta dialogrc_styles -> dialog.dialogrc e dialog(backup).dialogrc
# Pasta log -> err.txt e _1.txt

# Ficheiros que não se podem eleminar:
# Pasta dialogrc_styles e os seus ficheiros: dialog.dialogrc e dialog(backup).dialogrc

# Ficheiros que se podem eleminar:
# Pasta log e os seus ficheiros
# Ficheiros e pastas não mencionadas acima


# ficheiro que modifica o aspeto do GUI(tem de ser mudado manualmente)
if [ ! -f ./dialogrc_styles/dialog.dialogrc ];then
	dialog --create-rc "./dialogrc_styles/dialog.dialogrc"
fi
export DIALOGRC=./dialogrc_styles/dialog.dialogrc                                                 

# secção seguinte serve apenas para caso haja um problema de troca do /home por /root
Q_ROOT=$(id -u) # obtem 0 se estiver em root, e outro numero qualquer se for um user normal
if [ "$Q_ROOT" -eq 0 ];then
	GET_NAME=$(who) # obtem informação do utilizador, o nome, id, etc
	set -- $GET_NAME # não pôr dentro de aspas("")
  	PUT_NAME=$1 # guarda apenas o nome do utilizador

  	Q_PATH_H="/home/$PUT_NAME" # fica com o caminho certo obtendo o nome do utilizador(primeiro user)
else
  	Q_PATH_H="~" # fica como se fosse um caminho normal ao /home
fi

#definicao da funcao sucesso - verifica se a operação foi concluida corretamente
verifica() {
	if [ $? -eq 0 ];then # echo #? ou apenas $? -eq '0' vai dizer que é '0', se a operação anterior foi bem sucedida
  		dialog --msgbox "OK. Operação bem sucedida" 6 30
  	else
  		# o 2>err.txt serve para apanhar os erros, se acontecerem, e mais tarde mostra ao chamar esta função
  		errormsg=$(cat ./log/err.txt)
  		dialog --msgbox "Fail. Operação não foi bem sucedida, erro: ${errormsg}" 12 65
  	fi
}

sair() {
	dialog --title "Goodbye :)" --msgbox "A sair do programa..." 5 25
	sleep 2
	dialog --clear
	exit 0
}
#fim funcao

# /////////////////////////////////////	!LIVE CODE!	   /////////////////////////////////////

dialog --title "Hello There" --msgbox "Bem Vindo ao nosso programa!" 6 35
Q_PASS="z" # ao inserir a password, e não escrever nada, ele passa á frente como se estivesse certa, com isto(letra z) o ficheiro já nao fica vazio

sudo mkdir ./log
while true
do
	dialog --title "Hello There" --cancel-label "Exit" --insecure --passwordbox "Insira a password para fazer login:" 9 35 2>./log/_1.txt
	if [ $? -eq 1 ]; then sair; fi
	Q_PASS=$(cat ./log/_1.txt)
	
	if  [ "$Q_PASS" != "admin" ];then
		dialog --title "Password Errada" --msgbox "A password inserida está incorreta" 6 35
	else
		break
	fi
done



while true
do
	dialog --nocancel --menu "O que quer fazer?" 15 40 6 1 "Criar diretorio" 2 "Copiar ficheiros" 3 "Apagar ficheiros" 4 "Alterar nome do ficheiros" 5 "Exit/Sair" 2>./log/_1.txt
	Q_OP=$(cat ./log/_1.txt)

	case $Q_OP in
	1)
	 	dialog --title "Criar Diretorio" --inputbox "Qual o caminho (separe por / ou um '.' para o diretorio atual)? Diretoria Atual: $Q_PATH_H/" 11 45 2>./log/_1.txt
	 	if [ $? -eq 1 ]; then continue; fi # permite selecionar cancelar e voltar ao inicio
	   	Q_PATH=$(cat ./log/_1.txt)
	   	dialog --title "Criar Diretorio" --inputbox "Qual o nome do diretorio que quer criar em: $Q_PATH_H/$Q_PATH/<nome_dir>?" 9 45 2>./log/_1.txt
	   	if [ $? -eq 1 ]; then continue; fi
	   	Q_DIR=$(cat ./log/_1.txt)
	   	dialog --title "Criar Diretorio" --yesno "Tem a certeza que quer criar o diretório "$Q_DIR" no caminho em: $Q_PATH_H/$Q_PATH/?" 9 45
	   	if [ $? -eq 1 ]; then continue; fi
	   	
	   	sudo mkdir $Q_PATH_H/"$Q_PATH"/"$Q_DIR" 2>./log/err.txt
	   	verifica # chama função para verificar se a operação anterior teve sucesso
	;;
	2)

	   	# tentar fazer um progress bar (https://aurelio.net/shell/dialog/  na parte "5.8. Exemplo de cópia de arquivos com barra de progresso (Gauge)")
	   	            		
      		dialog --title "Copiar Ficheiros" --inputbox "Qual o caminho de origem (separe por / ou um '.' para o diretorio atual)? Diretoria Atual: $Q_PATH_H/" 11 50 2>./log/_1.txt
      		if [ $? -eq 1 ]; then continue; fi
    		Q_PATH=$(cat ./log/_1.txt)
    		
    		dialog --title "Copiar Ficheiros" --inputbox "Qual o caminho de destino (separe por / ou um '.' para o diretorio atual)? Diretoria Atual: $Q_PATH_H/" 11 50 2>./log/_1.txt
      		if [ $? -eq 1 ]; then continue; fi
    		Q_PATH_NEW=$(cat ./log/_1.txt)
    		
      		Q_FICH=$(ls $Q_PATH_H/"$Q_PATH" | sort)
      		ver=1
		if [ -n "$Q_FICH" ];then #verifica se tem ficheiros dentro da pasta
				
			COUNT=1
			RLIST=""
			for i in $Q_FICH; do
			    	RLIST="$RLIST $i $i off"		    
			done
			
			
			dialog --title "Copiar Ficheiros" --no-tags --radiolist "Diretoria: $Q_PATH_H/$Q_PATH " 27 35 20 ${RLIST} 2>./log/_1.txt
			if [ $? -eq 1 ]; then continue; fi
			Q_OP=$(cat ./log/_1.txt)
			
			dialog --title "Copiar Ficheiros" --yesno "Tem a certeza que quer copiar da diretoria $Q_PATH_H/$Q_PATH para a diretoria $Q_PATH_H/$Q_PATH_NEW os ficheiros: $Q_OP ?"  10 50
			if [ $? -eq 1 ]; then continue; fi

			# loop que copia um ficheiro de cada vez
			for i in $Q_OP; do
				sudo cp $Q_PATH_H/"$Q_PATH"/"$i" $Q_PATH_H/"$Q_PATH_NEW"/"$i" 2>./log/err.txt
				if [ $? -eq 0 ];then
					continue
				else
					errormsg=$(cat ./log/err.txt)
					dialog --nocancel --msgbox "O ficheiro "$i" não foi copiado. Erro: ${errormsg}" 12 65
					ver=0
					
				fi
			done
			if [ $ver -eq 0 ]; then
				continue
			fi
			 
			verifica  # quase desnecessario porque a verificação é feita acima, mas assim recebe um mensagem de sucesso
			
		else
			dialog --title "Copiar Ficheiros" --msgbox "Não existem ficheiros no diretorio: $Q_PATH_H/$Q_PATH" 9 40 
		fi
	   	
	;;
	3)
		dialog --menu "Apagar Ficheiro" 15 35 6 1 "Apagar um único ficheiro" 2 "Apagar vários ficheiros" 2>./log/_1.txt
		if [ $? -eq 1 ]; then continue; fi
	   	Q_OP2=$(cat ./log/_1.txt)
	   	
		case $Q_OP2 in
	    	1)
	    		dialog --title "Apagar um Ficheiro" --inputbox "Qual o caminho (separe por / ou um '.' para o diretorio atual)? Diretoria Atual: $Q_PATH_H/" 9 40 2>./log/_1.txt
	    		if [ $? -eq 1 ]; then continue; fi
	    		Q_PATH=$(cat ./log/_1.txt)
	    		
	    		Q_FICH=$(ls $Q_PATH_H/"$Q_PATH" | sort)
	      		
	      		ver=1
			if [ -n "$Q_FICH" ];then # verifica se tem ficheiros dentro da pasta
				
				# loop que vai permitir formatar o texto de modo a que tenha o fomrato correto para usar numa --checklist
				COUNT=1
				RLIST=""
				for i in $Q_FICH; do
				    	RLIST="$RLIST $i $i off"			    
				done
							
				dialog --title "Apagar um Ficheiro" --no-tags --radiolist "Diretoria: $Q_PATH_H/$Q_PATH " 27 35 20 ${RLIST} 2>./log/_1.txt
				if [ $? -eq 1 ]; then continue; fi
				Q_FICH=$(cat ./log/_1.txt)			   	
			   			    		
		    		dialog --title "Apagar um Ficheiro" --yesno "Tem a certeza que quer eliminar o ficheiro "$Q_FICH" no caminho em: $Q_PATH_H/$Q_PATH/?" 9 45
		   		if [ $? -eq 1 ]; then continue; fi
		   	
		    		sudo rm $Q_PATH_H/"$Q_PATH"/"$Q_FICH" 2>./log/err.txt
		    		verifica
	    		fi
	    	
	    	;;
	    	2)
	      		dialog --title "Apagar vários Ficheiros" --inputbox "Qual o caminho (separe por / ou um '.' para o diretorio atual)? Diretoria Atual: $Q_PATH_H/" 9 40 2>./log/_1.txt
	      		if [ $? -eq 1 ]; then continue; fi
	    		Q_PATH=$(cat ./log/_1.txt)
	      		Q_FICH=$(ls $Q_PATH_H/"$Q_PATH" | sort)
	      		
	      		ver=1
			if [ -n "$Q_FICH" ];then # verifica se tem ficheiros dentro da pasta
					
				# loop que vai permitir formatar o texto de modo a que tenha o fomrato correto para usar numa --checklist
				COUNT=1
				RLIST=""
				for i in $Q_FICH; do
				    	RLIST="$RLIST $i $i off"		    
				done
			
				
				dialog --title "Apagar vários Ficheiros" --no-tags --checklist "Diretoria: $Q_PATH_H/$Q_PATH " 27 35 20 ${RLIST} 2>./log/_1.txt
				if [ $? -eq 1 ]; then continue; fi
				Q_OP=$(cat ./log/_1.txt)
				
				dialog --title "Apagar vários Ficheiros" --yesno "Tem a certeza que quer eliminar os ficheiros selecionados?: $Q_OP" 9 40
				if [ $? -eq 1 ]; then continue; fi

				# loop que elemina um ficheiro de cada vez
				for i in $Q_OP; do
					sudo rm $Q_PATH_H/"$Q_PATH"/"$i" 2>./log/err.txt
					if [ $? -eq 0 ];then
						continue
					else
						errormsg=$(cat ./log/err.txt)
  						dialog --nocancel --msgbox "O ficheiro "$i" não foi eleminado. Erro: ${errormsg}" 12 65
  						ver=0
  					fi
				done
				if [ $ver -eq 0 ]; then
					continue
				fi
				verifica  # quase desnecessario porque a verificação é feita acima, mas assim recebe um mensagem de sucesso
				
				
			else #não a ficheiros presentes
				dialog --title "Apagar vários Ficheiros" --msgbox "Não existem ficheiros no diretorio: $Q_PATH_H/$Q_PATH" 9 40 
			fi
	    	;;
	    	esac
	;;
	4)
	   	dialog --title "Alterar nome do ficheiro" --inputbox "Qual o caminho (separe por / ou um '.' para o diretorio atual)? Diretoria Atual: $Q_PATH_H/" 10 55 2>./log/_1.txt
	   	if [ $? -eq 1 ]; then continue; fi
	   	Q_PATH=$(cat ./log/_1.txt)
	   	
	   	Q_FICH=$(ls $Q_PATH_H/"$Q_PATH" | sort)
	      		
      		ver=1
		if [ -n "$Q_FICH" ];then # verifica se tem ficheiros dentro da pasta
				
			# loop que vai permitir formatar o texto de modo a que tenha o fomrato correto para usar numa --checklist
			COUNT=1
			RLIST=""
			for i in $Q_FICH; do
			    	RLIST="$RLIST $i $i off"
			    	let COUNT++			    
			done
		
			
			dialog --title "Alterar nome do ficheiro" --no-tags --radiolist "Diretoria: $Q_PATH_H/$Q_PATH " 27 35 20 ${RLIST} 2>./log/_1.txt
			if [ $? -eq 1 ]; then continue; fi
			Q_FICH=$(cat ./log/_1.txt)
				
	   	
		   	dialog --title "Alterar nome do ficheiro" --inputbox "Qual o novo nome para o ficheiro $Q_FICH na pasta $Q_PATH_H/$Q_PATH? Insira o nome e o mesmo tipo de ficheiro -> Ex: file1.txt, file2.sh, ..." 10 55 2>./log/_1.txt
		   	if [ $? -eq 1 ]; then continue; fi
		   	Q_FICH_NEW=$(cat ./log/_1.txt)
		   	
		   	
		   	dialog --title "Alterar nome do ficheiro" --yesno "Tem a certeza que quer alterar o nome do ficheiro "$Q_FICH" para "$Q_FICH_NEW" no caminho em: $Q_PATH_H/$Q_PATH/?" 9 45
		   	if [ $? -eq 1 ]; then continue; fi
		   		
		   	sudo mv $Q_PATH_H/"$Q_PATH"/"$Q_FICH" $Q_PATH_H/"$Q_PATH"/"$Q_FICH_NEW" 2>./log/err.txt
		   	verifica
		 fi
	;;
	5)
	   	sair
	;;
	*)
	   	dialog --title "Erro Inesperado" --msgbox "Erro: $? " 6 25
	   	exit $?
	;;
	esac
done
sair
