pragma solidity ^0.6.0;

import "../protocol/upala.sol";
import "./upala-group.sol";
import "./base-prototype.sol";
import "../mockups/moloch-mock.sol";

// This Upala group auto-assigns scores to members of existing moloch based DAOs.
contract MolochGroup is UpalaGroup, BasePrototype {

    Moloch moloch;

    uint256 defaultLimit = 1000000 * 10 ** 18;  // one million dollars [*places little finger near mouth*]

    constructor (
        address upalaProtocolAddress,
        address poolFactory,
        address payable molochAddress
    ) UpalaGroup (
        upalaProtocolAddress,
        poolFactory
    ) BasePrototype (
        '{"name": "ProtoGroup","version": "0.1","description": "Autoassigns FakeDAI score to anyone who joins","join-terms": "No deposit required (ignore the ammount you see and join)","leave-terms": "No deposit - no refund"}',
        2 * 10 ** 18,
        0
    )
    public {
        upala = Upala(upalaProtocolAddress);
        moloch = Moloch(molochAddress);
        (groupID, groupPool) = upala.newGroup(address(this), poolFactory);
    }

    function _isMember(address candidate) internal view returns (bool) {
        (address delegateKey, uint256 shares, bool exists) = moloch.members(candidate);
        require(delegateKey == candidate, "Candidate is not a member or delegate");
        require(shares > 0, "Candidate has 0 shares");
        return exists;
    }

    function join(uint160 identityID) external {
        require(_isMember(msg.sender), "msg.sender is not a member");
        // TODO _isIdentityHolder require()
        _announceAndSetBotnetLimit(identityID, defaultLimit);
    }
}