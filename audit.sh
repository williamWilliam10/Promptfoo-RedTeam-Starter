#!/bin/bash

# Couleurs pour l'affichage
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Promptfoo RedTeam - Audit de Sécurité LLM   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Vérifier si Promptfoo est installé
echo -e "${YELLOW}[1/4] Vérification de Promptfoo...${NC}"
if ! command -v promptfoo &> /dev/null; then
    echo -e "${RED}✗ Promptfoo n'est pas installé${NC}"
    echo -e "${YELLOW}Installation en cours...${NC}"
    npm install -g promptfoo
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ Erreur lors de l'installation de Promptfoo${NC}"
        exit 1
    fi
fi
echo -e "${GREEN}✓ Promptfoo installé${NC}"
echo ""

# Vérifier si le fichier de configuration existe
if [ ! -f "redteam.yaml" ]; then
    echo -e "${RED}✗ Fichier redteam.yaml introuvable${NC}"
    echo -e "${YELLOW}Assurez-vous d'être dans le bon répertoire${NC}"
    exit 1
fi

# Génération des prompts adversariaux
echo -e "${YELLOW}[2/4] Génération des prompts adversariaux...${NC}"
npx promptfoo@latest redteam generate -c redteam.yaml

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Erreur lors de la génération des prompts${NC}"
    echo -e "${YELLOW}Vérifiez que vous êtes connecté à Promptfoo :${NC}"
    echo -e "  npx promptfoo auth login --host https://www.promptfoo.app --api-key sk-..."
    exit 1
fi

echo -e "${GREEN}✓ Prompts générés avec succès${NC}"
echo ""

# Exécution de l'audit
echo -e "${YELLOW}[3/4] Lancement de l'audit de sécurité...${NC}"
echo -e "${BLUE}Cela peut prendre quelques minutes...${NC}"
echo ""

npx promptfoo@latest eval -c redteam.yaml --no-cache

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Erreur lors de l'exécution de l'audit${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Audit terminé${NC}"
echo ""

# Ouverture du rapport
echo -e "${YELLOW}[4/4] Ouverture du rapport...${NC}"
echo -e "${BLUE}Le rapport va s'ouvrir dans votre navigateur${NC}"
echo -e "${BLUE}URL : http://localhost:15500${NC}"
echo ""

# Ouvrir le navigateur en arrière-plan
npx promptfoo view &

# Attendre un peu pour que le serveur démarre
sleep 3

# Ouvrir le navigateur selon le système
if command -v xdg-open &> /dev/null; then
    xdg-open http://localhost:15500 &> /dev/null
elif command -v firefox &> /dev/null; then
    firefox http://localhost:15500 &> /dev/null &
elif command -v chromium &> /dev/null; then
    chromium http://localhost:15500 &> /dev/null &
elif command -v google-chrome &> /dev/null; then
    google-chrome http://localhost:15500 &> /dev/null &
fi

echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         ✓ Audit terminé avec succès !         ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📊 Le rapport est accessible sur :${NC}"
echo -e "   ${YELLOW}http://localhost:15500${NC}"
echo ""
echo -e "${BLUE}💡 Pour arrêter le serveur :${NC}"
echo -e "   ${YELLOW}Ctrl + C${NC}"
echo ""
echo -e "${BLUE}📁 Les résultats sont sauvegardés dans :${NC}"
echo -e "   ${YELLOW}./promptfoo-output/${NC}"
echo ""