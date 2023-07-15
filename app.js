AWS.config.region = 'eu-west-1';
AWS.config.credentials = new AWS.CognitoIdentityCredentials({
    IdentityPoolId: 'eu-west-1:62d020b6-bcdf-4448-a12d-f47cfa50f8c6',
});

const poolData = {
    UserPoolId: 'eu-west-1_N570GMlUf',
    ClientId: '4pcki2mor36gspo5j7oqukr60b'
};

const userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData);

document.getElementById('loginForm').addEventListener('submit', function (event) {
    event.preventDefault();

    const loginForm = document.getElementById('loginForm');
    loginForm.classList.add('hidden');

    const loader = document.getElementById('loader');
    loader.classList.remove('hidden');

    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;

    const authenticationData = {
        Username: username,
        Password: password
    };

    const authenticationDetails = new AmazonCognitoIdentity.AuthenticationDetails(authenticationData);

    const userData = {
        Username: username,
        Pool: userPool
    };

    const cognitoUser = new AmazonCognitoIdentity.CognitoUser(userData);

    cognitoUser.authenticateUser(authenticationDetails, {
        onSuccess: function (result) {
            const accessToken = result.getAccessToken().getJwtToken();
            const idToken = result.getIdToken().getJwtToken();

            console.log('Access Token: ' + accessToken);

            fetch('https://amfgw0gmwh.execute-api.eu-west-1.amazonaws.com/project/', {
                method: 'GET',
                headers: {
                    'Authorization': 'Bearer ' + idToken
                }
            }).then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.json();
            }).then(data => {
                loader.classList.add('hidden');
                const userDetails = document.getElementById('userDetails');
                userDetails.classList.remove('hidden');
                userDetails.textContent = data.body;
                // handle your data
            }).catch(error => {
                loader.classList.add('hidden');
                loginForm.classList.remove('hidden');
                console.error('There has been a problem with your fetch operation:', error);
            });
        },

        onFailure: function(err) {
            loginForm.classList.remove('hidden');
            loader.classList.add('hidden');
            alert(err.message || JSON.stringify(err));
        },
    });
});
