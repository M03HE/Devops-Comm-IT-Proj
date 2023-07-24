AWS.config.region = 'eu-west-2';
AWS.config.credentials = new AWS.CognitoIdentityCredentials({
    IdentityPoolId: 'eu-central-1:2615cb15-c96b-4e59-a260-079281e5c9a8',
});

const poolData = {
    UserPoolId: 'eu-central-1_zNptvLNu5',
    ClientId: '7pvtn1mgvh96389qc1or5u07u1'
};

const userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData);
const message = document.getElementById('message');

document.getElementById('loginForm').addEventListener('submit', function (event) {
    event.preventDefault();

    const loginForm = document.getElementById('loginForm');
    loginForm.classList.add('hidden');
    const loader = document.getElementById('loader');
    loader.classList.remove('hidden');
    const signUp = document.getElementById('signUpButton');
    signUp.classList.add('hidden');
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
            message.textContent = '';  // Clear the error message on successful login

            fetch('https://uh6h859icd.execute-api.eu-central-1.amazonaws.com/Dev/', {
                method: 'GET',
                headers: {
                    'Authorization': 'Bearer ' + idToken
                }
            }).then(response => {
                if (!response.ok) {
                    message.textContent = 'Network response was not ok';
                }
                return response.json();
            }).then(data => {
                document.getElementById('loginForm').style.display = 'none';
                document.getElementById('signUpButton').style.display = 'none';
                loader.classList.add('hidden');
                const userDetails = document.getElementById('userDetails');
                userDetails.classList.remove('hidden');
                userDetails.textContent = data;
            }).catch(error => {
                loader.classList.add('hidden');
                loginForm.classList.remove('hidden');
                signUp.classList.remove('hidden');
                message.textContent = 'There has been a problem with your fetch operation: ' + error.message;
            });
        },

        onFailure: function (err) {
            loginForm.classList.remove('hidden');
            signUp.classList.remove('hidden');
            loader.classList.add('hidden');
            message.textContent = err.message || JSON.stringify(err);
        },
    });

    document.getElementById('username').addEventListener('input', function () {
        message.textContent = '';
    });
    document.getElementById('password').addEventListener('input', function () {
        message.textContent = '';
    });
});

document.getElementById('signupForm').addEventListener('submit', function (event) {
    event.preventDefault();

    const username = document.getElementById('signupUsername').value;
    const password = document.getElementById('signupPassword').value;
    const email = document.getElementById('signupEmail').value;
    var userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData);
    var attributeList = [];
    var dataEmail = {
        Name: 'email',
        Value: email,
    };

    var attributeEmail = new AmazonCognitoIdentity.CognitoUserAttribute(dataEmail);
    attributeList.push(attributeEmail);

    userPool.signUp(username, password, attributeList, null, function (err, result) {
        if (err) {
            message.textContent = err.message || JSON.stringify(err);
            return;
        }
        var cognitoUser = result.user;
        message.textContent = cognitoUser.getUsername() + ' Please verify your account via the confirmation email, and then proceed to log in.';
    });
    document.getElementById('signupUsername').addEventListener('input', function () {
        message.textContent = '';
    });
    document.getElementById('signupPassword').addEventListener('input', function () {
        message.textContent = '';
    });
    document.getElementById('signupEmail').addEventListener('input', function () {
        message.textContent = '';
    });
});

document.getElementById('signUpButton').addEventListener('click', function () {
    message.textContent = '';
    document.getElementById('signUpButton').style.display = 'none';
    document.getElementById('signupForm').style.display = 'block';
    document.getElementById('loginForm').style.display = 'none';
    document.getElementById('loginButton').style.display = 'block';
});

document.getElementById('loginButton').addEventListener('click', function () {
    message.textContent = '';
    document.getElementById('loginForm').style.display = 'block';
    document.getElementById('signupForm').style.display = 'none';
    document.getElementById('signUpButton').style.display = 'block';
    document.getElementById('loginButton').style.display = 'none';
});
