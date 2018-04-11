#!/bin/bash

PROJECT_NAME=`basename $(pwd)`
PYTHON_ENV="python-dev"

###################################################
# Setup Python environment.
###################################################

# Create virtual-env
python3 -m venv $PYTHON_ENV
$PYTHON_ENV/bin/python3 -m pip install flask pep8 autopep8

# app.py
echo "from flask import Flask

app = Flask(__name__, static_url_path='', static_folder='dist')

@app.route('/')
def index():
    return app.send_static_file('index.html')

if __name__ == '__main__':
    app.run(port=5000)
" > app.py

###################################################
# Setup Node.js environment.
###################################################

# package.json
echo "{
  \"name\": \"$PROJECT_NAME\",
  \"version\": \"1.0.0\",
  \"description\": \"\",
  \"main\": \"index.js\",
  \"scripts\": {
    \"build\": \"webpack\"
  },
  \"keywords\": [],
  \"author\": \"\",
  \"license\": \"MIT\"  
}" > package.json

# Install dependencies.
npm install -D webpack webpack-cli \
awesome-typescript-loader \
typescript tsc \
react @types/react \
react-dom @types/react-dom \
react-redux @types/react-redux redux \
react-router-redux @types/react-router-redux \
react-hot-loader @types/react-hot-loader \

# webpack.config.js
echo "module.exports = {
    entry: './src/boot-client.tsx',
    output: {
        filename: \"bundle.js\",
        path: __dirname + \"/dist\"
    },
    resolve: {
        extensions: ['.ts', '.tsx', '.js', '.jsx']
    },
    module: {
        rules: [
            {
                test: /\.(ts|tsx)?$/,
                loader: 'awesome-typescript-loader'
            }
        ]
    }
};" > webpack.config.js

# tsconfig.json
echo "{
  \"compilerOptions\": {
    \"target\": \"es5\",
    \"module\": \"commonjs\",
    \"jsx\": \"react\",
    \"strict\": true,
    \"moduleResolution\": \"node\",
    \"esModuleInterop\": true
  }
}" > tsconfig.json

###################################################
# Generate template.
###################################################
mkdir src
mkdir src/actions
mkdir src/components
mkdir src/containers
mkdir src/store
mkdir dist

# ./dist/index.html
echo "<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>$PROJECT_NAME</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
</head>

<body>
    <div id='app'></div>
    <script src='bundle.js'></script>
</body>

</html>" > ./dist/index.html

# ./src/store/index.ts
echo "import { combineReducers } from 'redux';

export interface ApplicationState {
}

export const reducer = combineReducers({
});" > ./src/store/index.ts

# ./src/configureStore.ts
echo "import { createStore } from 'redux';
import { ApplicationState, reducer } from './store';

export default function configureStore() {
    const store = createStore(
        reducer
    );
    return store;
}" > ./src/configureStore.ts

# ./src/boot-client.tsx
echo "import * as React from 'react';
import * as ReactDOM from 'react-dom';
import { AppContainer } from 'react-hot-loader';
import { Provider } from 'react-redux';
import configureStore from './src/configureStore';

const store = configureStore();

function renderApp() {
    ReactDOM.render(
        <AppContainer>
            <Provider store={ store }>
            </Provider>
        </AppContainer>,
        document.getElementById('app')
    );
}

renderApp();" > ./src/boot-client.tsx

###################################################
# Setup Visual Studio Code environment.
###################################################

mkdir .vscode

# ./.vscode/launch.json
echo "{
    \"version\": \"0.2.0\",
    \"configurations\": [
        {
            \"name\": \"Integrated Terminal/Console\",
            \"type\": \"python\",
            \"request\": \"launch\",
            \"stopOnEntry\": false,
            \"pythonPath\": \"\${config:python.pythonPath}\",
            \"program\": \"\${workspaceFolder}/app.py\",
            \"cwd\": \"\",
            \"console\": \"integratedTerminal\",
            \"env\": {},
            \"envFile\": \"\${workspaceFolder}/.env\",
            \"debugOptions\": [],
            \"internalConsoleOptions\": \"neverOpen\",
            \"preLaunchTask\": \"webpack-build\"
        }
    ]
}" > ./.vscode/launch.json

# ./.vscode/tasks.json
echo "{
    \"version\": \"2.0.0\",
    \"tasks\": [
        {
            \"label\": \"webpack-build\",
            \"type\": \"npm\",
            \"script\": \"build\",
            \"group\": {
                \"kind\": \"build\",
                \"isDefault\": true
            }
        }
    ]
}" > ./.vscode/tasks.json

# ./.vscode/settings.json
echo "{
    \"python.pythonPath\": \".\\$PYTHON_ENV\\Scripts\\python.exe\",
}" > ./.vscode/settings.json
