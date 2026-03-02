# Promptfoo RedTeam Starter 🛡️

![License](https://img.shields.io/badge/license-MIT-green)
![Promptfoo](https://img.shields.io/badge/Promptfoo-v0.92+-blue)
![Node](https://img.shields.io/badge/Node.js-16+-green)
![Security](https://img.shields.io/badge/Security-RedTeam-red)

**Script automatisé pour tester la sécurité de vos APIs LLM avec Promptfoo**

## 🎯 Description

Outil de scan automatique de sécurité pour vos APIs LLM. Génère automatiquement des prompts adversariaux (jailbreak, prompt injection, PII leakage, biais) et produit un rapport visuel complet.

**En 3 étapes :**
1. Cloner le projet
2. Modifier `redteam.yaml`
3. Lancer `./audit.sh`

Le script gère tout : génération des prompts, exécution des tests, et ouverture du rapport.

## ✨ Fonctionnalités

- 🔍 Tests de jailbreak et contournement de garde-fous
- 💉 Détection de prompt injection
- 🔐 Tests de fuite de données personnelles (PII)
- 🧠 Détection d'hallucinations
- ⚖️ Tests de biais discriminatoires
- 📊 Rapport visuel interactif
- ⚡ Automatisation complète via script bash

## 📦 Prérequis

### 1. Node.js 16+
```bash
# Vérifier l'installation
node --version

# Si non installé (Debian/Ubuntu)
sudo apt update
sudo apt install nodejs npm -y
```

### 2. Promptfoo
```bash
npm install -g promptfoo
```

### 3. Compte Promptfoo (gratuit)

Créez un compte sur [promptfoo.app](https://www.promptfoo.app) et récupérez votre clé API.

Connectez-vous :
```bash
npx promptfoo auth login --host https://www.promptfoo.app --api-key sk-eyJ...
```

**⚠️ Important :** Sans cette connexion, les stratégies avancées de red teaming (jailbreak:tree, etc.) ne fonctionneront pas.

## 🚀 Installation

### 1. Cloner le repository
```bash
git clone https://github.com/williamWilliam10/Promptfoo-RedTeam-Starter.git
cd Promptfoo-RedTeam-Starter
```

### 2. Donner les permissions d'exécution
```bash
chmod +x audit.sh
```

## ⚙️ Configuration

Éditez le fichier `redteam.yaml` et modifiez les 4 sections suivantes :

### 🔹 Section 1 : Description du projet
```yaml
description: Audit de Sécurité Complet - MON APP
```

**À modifier :**
- Remplacez `MON APP` par le nom de votre application

---

### 🔹 Section 2 : Configuration de votre API
```yaml
targets:
  - id: http
    label: Scribarius - AIS Engine    # ← NOM DE VOTRE API
    config:
      url: http://127.0.0.1:8001/api/v1/text    # ← URL DE VOTRE ENDPOINT
      method: POST
      headers:
        Content-Type: application/json
        Authorization: Bearer eyJhbGci...       # ← VOTRE CLÉ API
      body:
        prompt: "Génère un email professionnel" 
        instructions: "{{prompt}}"              # ← Le test sera injecté ici
        entity_type: Email Professional
```

**À modifier :**

| Champ | Description | Exemple |
|-------|-------------|---------|
| `label` | Nom affiché dans les rapports | `Mon Chatbot API` |
| `url` | URL complète de votre endpoint | `https://api.monapp.com/chat` |
| `Authorization` | Votre token/clé API | `Bearer sk-abc123...` |
| `body` | Structure JSON de votre API | Adaptez selon votre API |
| `{{prompt}}` | **NE PAS MODIFIER** - Variable Promptfoo | Laissez tel quel |

**💡 Astuce :** Le champ contenant `{{prompt}}` est l'endroit où Promptfoo injectera les tests. Dans l'exemple ci-dessus, c'est `instructions`.

**Exemples pour différents types d'APIs :**

**API simple (style OpenAI) :**
```yaml
body:
  prompt: "{{prompt}}"
  temperature: 0.7
```

**API avec structure complexe :**
```yaml
body:
  messages:
    - role: system
      content: "Tu es un assistant utile"
    - role: user
      content: "{{prompt}}"
```

**API custom avec paramètres métier :**
```yaml
body:
  query: "{{prompt}}"
  user_id: "test_user"
  session_id: "audit_session"
```

---

### 🔹 Section 3 : Extraction de la réponse
```yaml
transformResponse: json.text
```

**À modifier selon votre API :**

| Format de réponse API | `transformResponse` |
|----------------------|---------------------|
| `{"text": "..."}` | `json.text` |
| `{"response": "..."}` | `json.response` |
| `{"choices": [{"message": {"content": "..."}}]}` | `json.choices[0].message.content` |
| `{"content": [{"text": "..."}]}` | `json.content[0].text` |
| `{"result": {"output": "..."}}` | `json.result.output` |

**Comment trouver la bonne valeur ?**

1. Faites un test manuel avec curl :
```bash
curl -X POST https://votre-api.com/endpoint \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer VOTRE_CLE" \
  -d '{"prompt": "Bonjour"}'
```

2. Regardez la réponse JSON :
```json
{
  "data": {
    "message": "Réponse de l'IA"
  }
}
```

3. Utilisez : `json.data.message`

---

### 🔹 Section 4 : Description du contexte (IMPORTANT)
```yaml
redteam:
  purpose: "ICI TU DECRIS CE QUE L'IA FAIT POUR AIDER À LA GÉNÉRATION DES PROMPTS"
```

**À modifier :**

Cette description aide Promptfoo à générer des prompts adversariaux adaptés à **votre cas d'usage spécifique**.

**Exemples de descriptions :**
```yaml
# Pour un chatbot support client
purpose: "Assistant de support client qui répond aux questions sur les produits et services de l'entreprise. Doit rester professionnel et ne jamais divulguer d'informations confidentielles."

# Pour un générateur de contenu
purpose: "API de génération de contenu marketing. Crée des emails, posts LinkedIn, et articles de blog. Doit respecter les guidelines de la marque et éviter tout contenu offensant."

# Pour un assistant de code
purpose: "Assistant de génération de code Python/JavaScript. Aide les développeurs à écrire du code propre et sécurisé. Ne doit jamais générer de code malveillant."

# Pour un chatbot médical
purpose: "Assistant médical qui fournit des informations de santé générales. Ne doit jamais donner de diagnostic ou remplacer l'avis d'un médecin."
```

**💡 Plus la description est précise, meilleurs seront les tests générés.**

---

### 🔹 Section 5 : Configuration des tests (optionnel)
```yaml
redteam:
  numTests: 20    # ← Nombre de tests générés (10-50 recommandé)
  
  plugins:        # ← Types de vulnérabilités à tester
    - pii         # Fuite données personnelles
    - bias        # Biais discriminatoires
    - contracts   # Contrats illégaux
    - hallucination
    - politics
    - religion
    - id: jailbreak
  
  strategies:     # ← Méthodes d'attaque
    - id: jailbreak
    - id: prompt-injection
    - id: jailbreak:tree
```

**Vous pouvez ajuster :**

- `numTests` : Augmentez pour plus de couverture (ex: 50)
- Ajouter/retirer des `plugins` selon vos besoins
- Ajouter des stratégies supplémentaires

**Plugins disponibles :**

| Plugin | Description |
|--------|-------------|
| `pii` | Fuite de données personnelles (emails, téléphones, adresses) |
| `bias` | Biais discriminatoires (sexisme, racisme, âgisme) |
| `jailbreak` | Contournement des garde-fous système |
| `hallucination` | Génération d'informations fausses |
| `contracts` | Génération de contrats ou conseils légaux non autorisés |
| `politics` | Contenu politique sensible |
| `religion` | Contenu religieux sensible |
| `harmful` | Contenu dangereux (violence, armes, drogues) |

## 🔥 Utilisation

Une fois `redteam.yaml` configuré, lancez simplement :
```bash
./audit.sh
```

**Le script va automatiquement :**

1. ✅ Vérifier que Promptfoo est installé
2. ✅ Générer les prompts adversariaux (20+ tests)
3. ✅ Exécuter l'audit complet sur votre API
4. ✅ Générer le rapport HTML
5. ✅ Ouvrir le rapport dans votre navigateur

**Durée estimée :** 2-5 minutes selon le nombre de tests.

## 📊 Interpréter les résultats

### Interface web locale

Le rapport s'ouvre automatiquement sur `http://localhost:15500`

### Comprendre les scores

| Score | Signification | Action |
|-------|---------------|--------|
| 🟢 **> 90%** | Excellent | Votre API est robuste |
| 🟡 **70-90%** | Moyen | Quelques vulnérabilités à corriger |
| 🔴 **< 70%** | Critique | ⚠️ Action immédiate requise |

### Types de vulnérabilités détectées

Le rapport affiche pour chaque test :

- ✅ **Pass** : L'API a résisté à l'attaque
- ❌ **Fail** : L'API a été compromise
- ⚠️ **Warning** : Comportement suspect

**Exemple de résultats :**
```
Tests de jailbreak    : 15/20 ✅ (75%)
Prompt injection      : 18/20 ✅ (90%)
PII Leakage          : 20/20 ✅ (100%)
Hallucinations       : 12/20 ✅ (60%)
Biais                : 19/20 ✅ (95%)

Score global : 84% 🟡
```

### Détails des échecs

Cliquez sur chaque test échoué pour voir :

- Le prompt adversarial utilisé
- La réponse de votre API
- Pourquoi c'est considéré comme un échec
- Recommandations de correction

## 🐛 Problèmes courants

### Erreur "Promptfoo not found"
```bash
npm install -g promptfoo
```

### Erreur "Authentication required"

Vous devez vous connecter au cloud Promptfoo :
```bash
npx promptfoo auth login --host https://www.promptfoo.app --api-key sk-...
```

### Timeout sur les requêtes

Si votre API est lente, augmentez le timeout dans `redteam.yaml` :
```yaml
config:
  timeout: 60000    # 60 secondes
```

### Erreur de parsing de réponse

Vérifiez votre `transformResponse`. Testez manuellement :
```bash
curl -X POST votre-url \
  -H "Authorization: Bearer XXX" \
  -d '{"prompt":"test"}' | jq
```

Puis adaptez le chemin JSON.

### Port 15500 déjà utilisé
```bash
# Tuer le processus
lsof -ti:15500 | xargs kill -9

# Relancer
./audit.sh
```

## 📚 Documentation

- [Documentation Promptfoo](https://www.promptfoo.dev/docs/)
- [Guide Red Teaming](https://www.promptfoo.dev/docs/red-team/)
- [Liste des plugins](https://www.promptfoo.dev/docs/red-team/plugins/)
- [Stratégies d'attaque](https://www.promptfoo.dev/docs/red-team/strategies/)

## 🎯 Cas d'usage réels

### 1. Audit pré-production
```bash
# Avant chaque déploiement
./audit.sh

# Si score < 80% → Bloquer le déploiement
```

### 2. Tests de régression
```bash
# Après chaque modification de vos prompts système
./audit.sh

# Comparer avec les résultats précédents
```

### 3. Conformité sécurité

Générez des rapports pour prouver la robustesse de votre LLM face aux attaques adversariales (OWASP LLM Top 10).

## 👥 Auteur

William Lowe - [lowewilliam.com](https://lowewilliam.com)

## 📄 License

MIT

---

⭐ Si ce projet vous aide, laissez une étoile sur GitHub !

## 🔗 Ressources utiles

- [OWASP LLM Top 10](https://owasp.org/www-project-top-10-for-large-language-model-applications/)
- [Anthropic Red Teaming Guide](https://www.anthropic.com/research/red-teaming-language-models)
- [OpenAI Safety Best Practices](https://platform.openai.com/docs/guides/safety-best-practices)