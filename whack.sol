pragma solidity ^0.8.0;



/*
Accounts loading...
ERROR!
ERROR!
SEEK ADMINISTRATOR ASSISTANCE
Printing latest report...                                                                     
                                                                                
                                       ,########(##(####                        
                               ################,#,/*####                        
                             #################,##,#,####                        
                             ##################%%%%#####                        
                              #((((#####################,                       
                              ((((((((#####################                     
                           #((((((%(#@#@@##########(#(((((#(#                   
                          @(((((((((#%(((#%#%(((#%%%#(((((                      
                          ,((((((((((((#%((((&%%%%%%&&&&%                       
                           ((((((((((((((&((#((&#(((@&@,                        
                           @((((((((((((((((((((&(@                             
                           #((((((((((((((((&(((                                
                           ((((((((&((#&((((((@                                 
                          @(((@@@((((((((((@((.                                 
                          (((((((((((((@ @((@((@                                
                          ((((((((&((((((((((((/                                
                         #(((((((((((@(((((((&                                  
                         @((((((((((((((((((((                                  
                         %((((((((((((((((((((,                                 
                         (((((((((((((((((((((,                                 
                         (((((((((((((((((((((*                                 
                         (((((((((((((((((((((&                                 
                         &((((((((((((((((((((#                                 
                       /((((((((((((((((((((((                                  
                      @(((((((((((((((((((((@                                   
                          @((((((((@.@      @                                   
                           *     ,      @&& @                                   
                            %/. ( @             

                ALWAYS WANTED TO WHACK A WASSIE? NOW YOU CAN!

    Proof of Wassie is a game, an idea, a joke, an exploration of game theory and wassie extermination.
    
    This game has been built to help you, yes YOU, eliminate wassies like never before!

    The rules are simple:
    1) Call the whack() function to remotely, securely and viciously eliminate a wassie in our advanced facility, deep underground just North of [redacted]!
        -* This will cost you 0.001 Ethereum, as well as gas! *-
    2) Our proprietary [redacted] technology will digitally deliver the remains of the wassie YOU just assassinated directly to your wallet!
    3) Upon delivery, our in-house accounting team will increment your score by 1!
    

    Wassie Remains cannot be created ANY other way!

    That's the basics!

    In order to incentivise and further facilitate complete wassie genocide we are keeping the score of every user who assists in the cause!
    Whoever holds the highest score ("Record Holder") is able to call the claimReward() function at any time - this will reward them with 10% of the contract funds!
    However, if someone were to gain a higher score BEFORE the other user can claim the reward, the window of opportunity is closed and the reward cannot be claimed.
    A user MUST currently have the highest score in order to claim the reward.
    Additionally, the claimReward() function can only be called ONCE PER RECORD by a Record Holder. This means that once a reward is claimed, the Record Holder
    must allow another user to attain the highestScore in order to reset their claim status.

    We will also be inscribing our digital [redacted] tablets with a record of every user who attains the highest score, and the block they achieved it on!
    So, if you become a Record Holder (even if you don't claim the reward), you will be immortalised in our annals of wassie destruction as a true wassie slayer!
    
    You might have noticed the steal() function. This is a side business operated by unknown shadow entities in the accounting department. Likely a result of 
    the [redacted] incident.
    You can *bribe* these accountants to cook the books for you, letting you steal another user's score!

    To do this, they require: 0.0001 ETH per 1 Wassie Remains.
    They then use their patented [redacted] technology to reorganise the books in your favour!
    Keep in mind: You are only able to steal from those with a higher score than yourself!
    They will deduct score from your target and award score to you! Keeping everything balanced, in case of any pesky auditors!

    We here at Wassie Eradication and Internment Co. hope you enjoy utilising our unique services!

    -@yomidev_
    
*/

contract wassie is ERC20, Ownable {
    //constructor mints 100 wassie remains to dev for test purposes
    constructor() ERC20("Wassie Remains", "WASS") {
        _mint(msg.sender, 100);
    }

    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

    //each user's score is tracked in a mapping, as well as whether or not they have claimed
    //userTrophies mapping is to track which block a user has held the highest score for, as well as how many total.
    mapping (address => uint256) public score;
    mapping (address => bool) public hasClaimed;
    mapping (address => trophies) public userTrophies;

    address public devAddress = 0xd00d42FDA98e968d8EF446a7f8808103fA1b3fD6;
    address payable devWallet = payable(devAddress);

    //public variables to track everything
    //set previousRecordHolder to dead address to start and set dev to current recordHolder
    uint256 public totalKills = 0;
    uint256 public highestScore = 0;
    address public recordHolder = devAddress;
    address public previousRecordHolder = 0x000000000000000000000000000000000000dEaD;
    uint256 public price = 1000000000000000;
    uint256 public totalRewarded = 0;

    //this struct is used to keep track of the number of times a user has achieved "recordHolder" status, and which blocks they held it on!
    struct trophies {
        uint256 number;
        uint256[] blocks;
    }
    

    //main "game loop":
    //users kill a wassie by calling this function
    //users recieve wassie remains (ERC20) as proof of the kill
    //if the user's new score is higher than the current highest score we call highscoreUpdate()
    function whack() public payable {
        require(msg.value == price);
        score[msg.sender]++;
        _mint(msg.sender, 1);
        totalKills++;
        if(score[msg.sender] > highestScore){
            highscoreUpdate(score[msg.sender], msg.sender);
        }
    }

    //users can call the steal() function whenever they like, and target any other user who has more score than themselves when they do it
    //require statements ensure the target has enough score, attacker has enough Wassie Remains and that target's score is HIGHER than attackers
    //if the fee is paid the Wassie Remains get burned, the targets score will DECREASE by the amount of Wassie Remains burned
    //the attacker's score will also INCREASE by the amount of Wassie Remains burned.
    function steal(address _target, uint256 _amount) public payable {
        require(_amount > 0, "You can't steal 0 points!!");
        require(score[msg.sender] < score[_target], "Your target has less score than you! Don't be heartless!");
        require(balanceOf(msg.sender) >= _amount, "You don't have enough Wassie Remains!");
        require(msg.value == _amount * (price/10), "You need to pay more to grease the palms of the accountants. The price is 0.0001 ETH per Wassie Remains!");
        require(score[_target] >= (_amount), "Target doesn't have enough score!");
        _burn(msg.sender, _amount);
        score[_target] -= (_amount);
        score[msg.sender] += (_amount);
        if(score[msg.sender] > score[recordHolder]){
            highscoreUpdate(score[msg.sender], msg.sender);
        }
    }

    //called when a users score exceeds the current highestScore
    //set previousRecordHolder to the current recordHolder, then check that it isn't the same user (this prevents claiming more than once)
    //if previousRecordHolder is NOT the user this means that the user has "stolen" the highestScore
    //we then set the user's claim state to FALSE (hasClaim[_user] = false)
    //after this we update the highestScore and recordHolder variables
    //then increment user's trophy count, as well as push current block number to userTrophies[_user]
    function highscoreUpdate(uint256 _userScore, address _user) private {
        previousRecordHolder = recordHolder;
        if(previousRecordHolder != _user){
            hasClaimed[_user] = false;
        }
        highestScore = _userScore;
        recordHolder = _user;
        userTrophies[_user].number++;
        userTrophies[_user].blocks.push(block.number);
    }

    //returns current highest score, and user who holds it
    function getHighestScore() public view returns(uint256, address){
        return (highestScore, recordHolder);
    }

    //returns user trophy information
    function getUsertrophies(address _user) public view returns(uint256, uint256[] memory){
        return (userTrophies[_user].number, userTrophies[_user].blocks);
    }

    //If a user is the current highestScore holder they are able to claim 10% of the contract ETH balance
    //Users can only claim this reward ONCE for every time they take the highestScore
    //If a user claims once, and continues to hold the record, they are unable to claim again until ANOTHER user gets a higher score
    //This is handled in the require statements
    //The dev cut is 10% of the 10% reward, which gets deducted from the total pool
    function claimReward() public payable {
        require(msg.sender == recordHolder, "You are not the record holder!");
        require(hasClaimed[msg.sender] == false, "You have already claimed! Someone else must beat your record. Then you can take it back and claim again!");
        uint256 rewardAmount = address(this).balance/10;
        uint256 devCut = rewardAmount/10;
        hasClaimed[msg.sender] = true;
        payable(recordHolder).transfer(rewardAmount);
        payable(devAddress).transfer(devCut);
        totalRewarded += rewardAmount;
    }


    //onlyOwner function to change the price of calling the whack() function
    function setPrice(uint256 _newPrice) public onlyOwner {
        price = _newPrice;
    }

    function getTotalRewarded() public view returns(uint256){
        return totalRewarded;
    }

}
