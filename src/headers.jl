using BitIntegers
BitIntegers.@define_integers 24


abstract type Entry end

@enum ServiceEntryType::UInt8 FindService=0 OfferService=1 StopOfferService=2
Base.convert(::Type{ServiceEntryType}, a::Integer)=ServiceEntryType(a)
struct ServiceEntry <: Entry 
    type::ServiceEntryType
    idx_1_opt_run::UInt8
    idx_2_opt_run::UInt8
    num_opts::UInt8
    service_id::UInt16
    instance_id::UInt16
    major_ver::UInt8
    ttl::UInt24
    minor_ver::UInt32
end

@enum EventGroupEntryType::UInt8 Subscribe=0x06 SubscribeAck=0x07
Base.convert(::Type{EventGroupEntryType}, a::Integer)=EventGroupEntryType(a)
struct EventGroupEntry <: Entry
    type::EventGroupEntryType
    idx_1_opt_run::UInt8
    idx_2_opt_run::UInt8
    num_opts::UInt8
    service_id::UInt16
    instance_id::UInt16
    major_ver::UInt8
    ttl::UInt24
    init_resrvd_ctr::UInt8
    event_group_id::UInt16
end

@enum OptionType::UInt8  begin 
    ConfigurationOptionType=0x01
    LoadBalancingOptionType=0x02
    IPv4EndpointOptionType=0x04
    IPv6EndpointOptionType=0x06
    IPv4MulticastOptionType=0x14
    IPv6MulticastOptionType=0x16
    IPv4SDEndpointOptionType=0x24
    IPv6SDEndpointOptionType=0x26
end
Base.convert(::Type{OptionType}, a::Integer)=OptionType(a)

abstract type Option end

mutable struct ConfigurationOption <: Option
    length::UInt16
    const type::OptionType
    const discardable_reserved::UInt8
    configuration_string::String

    function ConfigurationOption(configuration_string::String;discardable::Bool=false)
        len = 1+sizeof(configuration_string)
        if discardable
            new(len, ConfigurationOptionType, 0x80, configuration_string)
        else
            new(len, ConfigurationOptionType, 0x00, configuration_string)
        end
    end
end

mutable struct LoadBalancingOption <: Option
    const length::UInt16
    const type::OptionType
    const reserved::UInt8
    priority::UInt16
    weight::UInt16

    function LoadBalancingOption(priority::Integer, weight::Integer)
        new(5, 2, 0, priority, weight)
    end
end

@enum TransportProtocolType::UInt8 TCP=0x06 UDP=0x11
Base.convert(::Type{TransportProtocolType}, a::Integer)=TransportProtocolType(a)

mutable struct IPv4EndpointOption <: Option
    const length::UInt16
    const type::OptionType
    const reserved::UInt8
    ipv4_address::Vector{UInt8}
    const reserved_2::UInt8
    transport_protocol::TransportProtocolType
    transport_protocol_port::UInt16

    function IPv4EndpointOption(ipv4_address::Vector{UInt8}, transport_protocol::Union{TransportProtocolType,Integer}, transport_protocol_port::Integer)
        if length(ipv4_address) != 4 
            error("IPv4 address must be 4 bytes long")
        end
        new(9, IPv4EndpointOptionType, 0, ipv4_address, 0, transport_protocol, transport_protocol_port)
    end
end

#mutable struct IPv6EndpointOption <: Option
#    const length::UInt16
#    const type::OptionType
#    const reserved::UInt8
#    ipv6_address[32]::Vector{UInt8}
#    const reserved_2::UInt8
#    transport_protocol::TransportProtocolType
#    transport_protocol_port::UInt16
#
#    function IPv6EndpointOption(ipv6_address::Integer, transport_protocol::Union{TransportProtocolType,Integer}, transport_protocol_port::Integer)
#        if ipv6_address > typemax(UInt128)
#            error("IPv6 address cannot be more than uint128max")
#        end
#        new(0x0015, 6, 0, unsafe_wrap(Array, ipv6_address), 0, transport_protocol, transport_protocol_port)
#    end
#end

mutable struct IPv6EndpointOption <: Option

    const length::UInt16
    const type::OptionType
    const reserved::UInt8
    const ipv6_address::Vector{UInt8}
    const reserved_2::UInt8
    transport_protocol::TransportProtocolType
    transport_protocol_port::UInt16

    function IPv6EndpointOption(ipv6_address::Vector{UInt8}, transport_protocol::Union{TransportProtocolType,Integer}, transport_protocol_port::Integer)
        if length(ipv6_address)!=16
            error("IPv6 address must be 16 bytes long")
        end
        new(0x0015, IPv6EndpointOptionType, 0, ipv6_address, 0, transport_protocol, transport_protocol_port)
    end

end

mutable struct IPv4MulticastOption <: Option
    const length::UInt16
    const type::OptionType
    const discardable_reserved::UInt8
    ipv4_address::Vector{UInt8}
    const reserved_2::UInt8
    const transport_protocol::TransportProtocolType
    transport_protocol_port::UInt16

    function IPv4MulticastOption(ipv4_address::Vector{UInt8}, transport_protocol_port::Integer)
        if length(ipv4_address) != 4 
            error("IPv4 address must be 4 bytes long")
        end
        new(9, IPv4MulticastOptionType, 0, ipv4_address, 0, UDP, transport_protocol_port)
    end
end

mutable struct IPv6MulticastOption <: Option
    const length::UInt16
    const type::OptionType
    const discardable_reserved::UInt8
    ipv6_address::Vector{UInt8}
    const reserved_2::UInt8
    const transport_protocol::TransportProtocolType
    transport_protocol_port::UInt16

    function IPv6MulticastOption(ipv6_address::Vector{UInt8}, transport_protocol_port::Integer)
        if length(ipv6_address)!=16
            error("IPv6 address must be 16 bytes long")
        end
        new(0x0015, IPv4MulticastOptionType, 0, ipv6_address, 0, UDP, transport_protocol_port)
    end
end

mutable struct IPv4SDEndpointOption <: Option
    const length::UInt16
    const type::OptionType
    const reserved::UInt8
    ipv4_address::Vector{UInt8}
    const reserved_2::UInt8
    const transport_protocol::TransportProtocolType
    const transport_protocol_port::UInt16

    function IPv4SDEndpointOption(ipv4_address::Vector{UInt8})
        if length(ipv4_address) != 4 
            error("IPv4 address must be 4 bytes long")
        end
        new(9, IPv4SDEndpointOptionType, 0, ipv4_address, 0, UDP, 30490)
    end
end

mutable struct IPv6SDEndpointOption <: Option

    const length::UInt16
    const type::OptionType
    const reserved::UInt8
    const ipv6_address::Vector{UInt8}
    const reserved_2::UInt8
    const transport_protocol::TransportProtocolType
    transport_protocol_port::UInt16

    function IPv6SDEndpointOption(ipv6_address::Vector{UInt8})
        if length(ipv6_address)!=16
            error("IPv6 address must be 16 bytes long")
        end
        new(0x0015, IPv6SDEndpointOptionType, 0, ipv6_address, 0, UDP, 30490)
    end
end

struct SDHeader
    message_id::UInt32
    length::UInt32
    client_id::UInt16
    session_id::UInt16
    protocol_version::UInt8
    interface_version::UInt8
    message_type::UInt8
    return_code::UInt8
    flags::UInt8
    reserved::UInt24
    len_entries_array::UInt32
    entries_array::Array{Entry}
    len_options_array::UInt32
    options_array::Array{Option}
end

#function SDHeader(client_id::UInt16,session_id::UInt16,
#        flags::UInt8,entries::Array{Entry},options::Array{Option}) 
#    new(0xFFFF8100, 0, 0, 1, 1, 1, 2, 0, 0, 0, )
#end

# h = IPv6EndpointOption(UInt8[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16], UDP, 3333)
# for f in fieldnames(IPv6EndpointOption)
#   @show sizeof(getproperty(h,f))
# end
#
# using Sockets
# group = ip"228.5.6.7"
# socket = Sockets.UDPSocket()
# send(socket, group, 6789, "Hello over IPv4")
# close(socket)
