#!/bin/sh
#Faz questões e guarda resposta

Q_ROOT=$(id -u) # obtem 0 se estiver em root, e outro numero qualquer se for um user normal
if [ $Q_ROOT -eq 0 ];then
	GET_NAME=$(who) # obtem informação do utilizador, o nome, id, etc
	set -- $GET_NAME
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
  	errormsg=$(cat err.txt)
  	dialog --msgbox "Fail. Operação não foi bem sucedida, erro: ${errormsg}" 12 65
  fi
}
#fim funcao

# /////////////////////////////////////	!LIVE CODE!	   /////////////////////////////////////

Q_PASS="z" # ao inserir a password, e não escrever nada, ele passa á frente como se estivesse certa, com isto(letra z) o ficheiro já nao fica vazio
dialog --title "Hello There" --msgbox "Bem Vindo ao nosso programa!" 6 35

while true
do
	dialog --title "Hello There" --inputbox "Insira a password para fazer login:" 8 30 2>_1.txt
	Q_PASS=$(cat _1.txt)
	if  [ $Q_PASS != $Q_PASS2 ];then
	  dialog --msgbox "Password Errada :(" 5 25
	else
	  break
	fi
done

while true
do
	dialog --menu "O que quer fazer?" 15 40 6 1 "Criar diretorio" 2 "Copiar ficheiros" 3 "Apagar ficheiros" 4 "Alterar nome do ficheiros" 5 "Exit/Sair" 2>_1.txt 
	Q_OP=$(cat _1.txt)

	case $Q_OP in
	 1)
	   dialog --title "Criar Diretorio" --inputbox "Qual o caminho(separe por /)?" 8 30 2>_1.txt
	   Q_PATH=$(cat _1.txt)
	   dialog --title "Criar Diretorio" --inputbox "Qual o nome do diretorio que quer criar em: ~/${Q_PATH}/<nome_dir>?" 8 40 2>_1.txt
	   Q_NAME=$(cat _1.txt)
	   sudo mkdir $Q_PATH_H/$Q_PATH/$Q_NAME 2>err.txt # o 2>err.txt serve para apanhar os erros, se acontecerem, e mais tarde mostra ao utilizador na função acima
	   verifica # chama função para verificar se a operação anterior teve sucesso
	 ;;
	 2)
	   dialog --title "Copiar Ficheiros" --msgbox "Mais aqui" 8 30
	 ;;
	 3)
	   dialog --menu "Apagar Ficheiro" 15 35 6 1 "Apagar um único ficheiro" 2 "Apagar vários ficheiros" 2>_1.txt 
	   Q_OP2=$(cat _1.txt)
	   case $Q_OP2 in
	    1)
	      dialog --title "Apagar Ficheiro" --inputbox "Qual o caminho(separe por /)?" 8 35 2>_1.txt
	      Q_PATH=$(cat _1.txt)
	      dialog --title "Apagar Ficheiro" --inputbox "Qual o ficheiro que quer apagar, dentro de ~/${Q_PATH}/<nome_fich> ?" 8 40 2>_1.txt
	      Q_FICH=$(cat _1.txt)
	      sudo rm $Q_PATH_H/$Q_PATH/$Q_FICH 2>err.txt
	      verifica
	    ;;
	    2)
	      # Pedir caminho da pasta e depois mostrar todos os nomes de ficheiros lá dentro para fazer escolha multipla
	    ;;
	    esac
	 ;;
	 4)
	   dialog --title "Alterar nome do ficheiro" --inputbox "Qual o caminho(separe por /)?" 10 45 2>_1.txt
	   Q_PATH=$(cat _1.txt)
	   dialog --title "Alterar nome do ficheiro" --inputbox "Qual o ficheiro a que quer mudar o nome? Insira o tipo de ficheiro -> Ex: file1.txt, file2.sh, ..." 10 45 2>_1.txt
	   Q_FICH=$(cat _1.txt)
	   dialog --title "Alterar nome do ficheiro" --inputbox "Qual o novo nome para o ficheiro ${Q_FICH}? Insira o tipo de ficheiro -> Ex: file1.txt, file2.sh, ..." 10 45 2>_1.txt
	   Q_FICH_NEW=$(cat _1.txt)
	   sudo mv $Q_PATH_H/$Q_PATH/$Q_FICH $Q_PATH_H/$Q_PATH/$Q_FICH_NEW 2>err.txt
	   verifica
	 ;;
	 5)
	   dialog --title "Goodbye :)" --msgbox "A sair do programa..." 5 25
	   sleep 2
	   dialog --clear
	   exit 0
	 ;;
	 *)
	   dialog --title "ERROR" --msgbox "	Erro Inexperado" 5 25
	   sleep 2
	   dialog --clear
	   exit 0
	 ;;
	esac
done

sleep 2
dialog --clear
exit 0
