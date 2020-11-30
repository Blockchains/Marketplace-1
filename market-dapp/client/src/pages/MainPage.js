import React, { Component } from 'react';
import { Button, Card, ListGroup } from 'react-bootstrap';
import { Link } from 'react-router-dom';
import { Redirect } from "react-router-dom";

import "../css/mainpage.css";

class MainPage extends Component {

    constructor(props) {
        super(props);

        this.state = {
            drizzle: props.drizzle,
            drizzleState: props.drizzleState,
            listCars: [],
            listSkins: [],
            redirectBuyItem: false,
            selectedTrack: "",
            selectedSimulator: "",
            selectedSeason: "",
            selectedPrice: "",
            selectedCarBrand: "",
        }

    }

    componentDidMount = async () => {
        const contract = await this.state.drizzle.contracts.IPFSInbox
        const response_cars = await contract.methods.getCars().call();
        const response_skins = await contract.methods.getSkins().call();
        this.setState({ listCars: response_cars, listSkins: response_skins });
    }


    buyItem = async (event, track, simulator, season, price, carBrand, address) => {
        event.preventDefault();

        this.setState({
            redirectBuyItem: true,
            selectedTrack: track,
            selectedSimulator: simulator,
            selectedSeason: season,
            selectedPrice: price,
            selectedCarBrand: carBrand,
            vendorAddress: address
        });
    }


    render() {

        const cars = [];
        const skins = [];

        if (this.state.redirectBuyItem == true) {
            return (<Redirect
                to={{
                    pathname: "/item",
                    state: {
                        selectedTrack: this.state.selectedTrack,
                        selectedSimulator: this.state.selectedSimulator,
                        selectedSeason: this.state.selectedSeason,
                        selectedPrice: this.state.selectedPrice,
                        selectedCarBrand: this.state.selectedCarBrand,
                    }
                }}
            />)
        }

        if (this.state.listCars != null || this.state.listSkins != null) {

            for (const [index, value] of this.state.listCars.entries()) {
                let carBrand = value.carBrand
                let track = value.track
                let simulator = value.simulator
                let season = value.season
                let price = value.price
                let address = value._address
                cars.push(
                    <ListGroup.Item key={index}>
                        <Card className="card-block" key={index}>
                            <Card.Body>
                                <Card.Title>{carBrand}</Card.Title>
                                <Card.Text>
                                    <div><b>Track:</b> {track}</div>
                                    <div><b>Simulator:</b> {simulator}</div>
                                    <div><b>Season:</b> {season}</div>
                                    <div><b>Price:</b> {price}</div>
                                    <div><b>Vendor address:</b> {address}</div>
                                </Card.Text>
                                <Button variant="primary" onClick={(e) => this.buyItem(e, track, simulator, season, price, carBrand, address)}> Buy</Button>
                            </Card.Body>
                        </Card>
                    </ListGroup.Item>
                )
            }

            for (const [index, value] of this.state.listSkins.entries()) {
                let carBrand = value.carBrand
                let simulator = value.simulator
                let price = value.price
                let address = value._address
                skins.push(
                    <ListGroup.Item key={index}>
                        <Card className="card-block">
                            <Card.Body>
                                <Card.Title>{carBrand}</Card.Title>
                                <Card.Text>
                                    <div><b>Simulator:</b> {simulator}</div>
                                    <div><b>Price:</b> {price}</div>
                                    <div><b>Vendor address:</b> {address}</div>
                                </Card.Text>
                                <Button variant="primary" onClick={(e) => this.buyItem(e, null, simulator, null, price, carBrand , address)}> Buy</Button>
                            </Card.Body>
                        </Card>
                    </ListGroup.Item>
                )
            }
        }

        return (
            <div>
                <div className="center-text">
                    <h1 >Items</h1>
                </div>
                <div>
                    <h4>Available Cars Setups</h4>
                </div>
                <div>
                    <ListGroup className="list-group list-group-horizontal scrolling-wrapper">
                        {cars}
                    </ListGroup>

                </div>
                <br></br>
                <div>
                    <h4> Available Cars Skins</h4>
                </div>
                <div>
                    <ListGroup className="list-group list-group-horizontal scrolling-wrapper">
                        {skins}
                    </ListGroup>
                </div>
                <br>
                </br>
            </div>
        );
    }
}

export default MainPage;