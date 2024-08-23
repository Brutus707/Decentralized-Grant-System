// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GrantSystem {
    address public admin;

    // Structure to store grant application details
    struct GrantApplication {
        string proposal;
        uint256 amountRequested;
        address applicant;
        bool funded;
    }

    // List of all grant applications
    GrantApplication[] public applications;

    // Events for logging
    event ApplicationSubmitted(uint256 applicationId);
    event ApplicationFunded(uint256 applicationId, uint256 amount);
    event FundingAttempt(uint256 applicationId, uint256 requestedAmount, uint256 sentAmount);

    constructor() {
        admin = msg.sender;
    }

    // Function to submit a new grant application
    function submitApplication(string memory _proposal, uint256 _amountRequested) public {
        require(_amountRequested > 0, "Requested amount must be greater than zero");

        applications.push(GrantApplication({
            proposal: _proposal,
            amountRequested: _amountRequested,
            applicant: msg.sender,
            funded: false
        }));

        emit ApplicationSubmitted(applications.length - 1);
    }

    // Function to fund a grant application
    function fundApplication(uint256 _applicationId) public payable {
        require(msg.sender == admin, "Only admin can fund applications");
        require(_applicationId < applications.length, "Invalid application ID");
        require(!applications[_applicationId].funded, "Application already funded");

        GrantApplication storage app = applications[_applicationId];

        emit FundingAttempt(_applicationId, app.amountRequested, msg.value);

        // Ensure the sent amount matches the requested amount
        // require(msg.value == app.amountRequested, "Incorrect funding amount");

        // Mark the application as funded
        app.funded = true;

        // Transfer funds to the applicant
        (bool success, ) = payable(app.applicant).call{value: msg.value}("");
        require(success, "Transfer failed.");

        emit ApplicationFunded(_applicationId, msg.value);
    }

    // Function to retrieve application details
    function getApplication(uint256 _applicationId) public view returns (string memory, uint256, address, bool) {
        require(_applicationId < applications.length, "Invalid application ID");
        GrantApplication memory app = applications[_applicationId];
        return (app.proposal, app.amountRequested, app.applicant, app.funded);
    }
}
